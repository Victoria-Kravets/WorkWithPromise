//
//  Promise.swift
//  Promise
//
//  Created by Andrew Barba on 9/30/16.
//  Copyright © 2016 Andrew Barba. All rights reserved.
//

/// Enum representing the current state of a Promise
///
/// - pending:  in a pending state, neither resolved or rejected
/// - resolved: resolved. the promise can never change to another state
/// - rejected: rejected. the promise can never change to another state
public enum State<T> {
    case pending
    case resolved(_: T)
    case rejected(_: Error)
    
    /// Is this a pending state
    public var isPending: Bool {
        switch self {
        case .pending:
            return true
        default:
            return false
        }
    }
    
    /// The resolved result
    public var result: T? {
        switch self {
        case .resolved(let result):
            return result
        default:
            return nil
        }
    }
    
    /// The rejected error
    public var error: Error? {
        switch self {
        case .rejected(let error):
            return error
        default:
            return nil
        }
    }
}

/// Handler function to be called when a Promise changes state
///
/// - resolve: block to be called if Promise resolves
/// - reject:  block to be called if Promise rejects
internal enum StateHandler<T> {
    case resolve(_: DispatchQueue, _: (T) -> Void)
    case reject(_: DispatchQueue, _: (Error) -> Void)
}

open class Promise<Result> {
    
    /// Handlers to be called when the promise changes state
    private var stateHandlers: [StateHandler<Result>] = []
    
    /// Private dispatch queue for performing state related operations
    private let stateQueue = DispatchQueue(label: "com.abarba.Bluebird.state", qos: .userInteractive)
    
    /// The current state of the promise
    public private(set) var state: State<Result>
    
    /// Is this Promise in a pending state
    public var isPending: Bool {
        return stateQueue.sync {
            state.isPending
        }
    }
    
    /// The resolved result of the promise
    public var result: Result? {
        return stateQueue.sync {
            return state.result
        }
    }
    
    /// The rejected error of the promise
    public var error: Error? {
        return stateQueue.sync {
            return state.error
        }
    }
    
    /// Initialize to a resolved result
    ///
    /// - parameter result: the final result of the promise
    ///
    /// - returns: Promise
    public init(resolve result: Result) {
        self.state = .resolved(result)
    }
    
    /// Initializa to a rejected error
    ///
    /// - parameter error: the final error of the promise
    ///
    /// - returns: Promise
    public init(reject error: Error) {
        self.state = .rejected(error)
    }
    
    /// Initialize using a resolver function
    ///
    /// - parameter resolver: takes in a two blocks, one to resolve and one to reject the promise. Can be called synchronously or asynchronously
    ///
    /// - returns: Promise
    public init(_ resolver: (@escaping (Result) -> Void, @escaping (Error) -> Void) throws -> Void) {
        self.state = .pending
        do {
            try resolver({
                self.set(state: .resolved($0))
            }, {
                self.set(state: .rejected($0))
            })
        } catch {
            set(state: .rejected(error))
        }
    }
    
    /// Convenience initializer to resolve this Promise when a returned Promise is resolved
    ///
    /// - parameter resolver: block that returns a Promise that this Promise will resolve to
    ///
    /// - returns: Promise
    public convenience init(_ resolver: () throws -> Promise<Result>) {
        self.init { resolve, reject in
            try resolver().addHandlers([
                .resolve(.main, resolve),
                .reject(.main, reject)
            ])
        }
    }
    
    deinit {
        stateQueue.sync {
            stateHandlers = []
        }
    }
    
    /// Safely set the state of this Promise
    ///
    /// - parameter state: the new state of the Promise
    private func set(state newState: State<Result>) {
        stateQueue.sync {
            guard case .pending = state else { return }
            
            state = newState
            
            stateHandlers.forEach { handler in
                switch (state, handler) {
                case (.resolved(let result), .resolve(let queue, let block)):
                    queue.async { block(result) }
                case (.rejected(let error), .reject(let queue, let block)):
                    queue.async { block(error) }
                default:
                    break
                }
            }
            
            stateHandlers = []
        }
    }
    
    /// Adds handlers that will be run when this Promise resolves or rejects
    ///
    /// - parameter queue:   the dispatch queue to run the passed in handlers on
    /// - parameter resolve: a block to run when the Promise resolves
    /// - parameter reject:  a block to run when the Promise rejects
    ///
    /// - returns: Self
    @discardableResult
    internal func addHandlers(_ handlers: [StateHandler<Result>]) -> Promise<Result> {
        return stateQueue.sync {
            switch state {
            case .pending:
                stateHandlers.append(contentsOf: handlers)
            case .resolved(let result):
                handlers.forEach { runHandler($0, with: result) }
            case .rejected(let error):
                handlers.forEach { runHandler($0, with: error) }
            }
            return self
        }
    }
    
    /// Runs a handler if it is a resolve handler
    ///
    /// - parameter handler: handler to run
    /// - parameter result:  resolved result
    private func runHandler(_ handler: StateHandler<Result>, with result: Result) {
        switch handler {
        case .resolve(let queue, let block):
            queue.async { block(result) }
        default:
            break
        }
    }
    
    /// Runs a handler if it is a reject handler
    ///
    /// - parameter handler: handler to run
    /// - parameter error:   resolved error
    private func runHandler(_ handler: StateHandler<Result>, with error: Error) {
        switch handler {
        case .reject(let queue, let block):
            queue.async { block(error) }
        default:
            break
        }
    }
}

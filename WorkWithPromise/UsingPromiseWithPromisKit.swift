//
//  UsingPromiseWithPromisKit.swift
//  WorkWithPromise
//
//  Created by Viktoria on 8/7/17.
//  Copyright © 2017 Viktoria. All rights reserved.
//

import Foundation
import PromiseKit
class UsingPromiseWithPromisKit{
     let start = Date()
    func usePromise(){

        let str = "Start of woking promiseKit"
        var arr = [Promise<String>]()
        let result = displayMessage(str: str)
        for count in 0...1000000{
            arr.append(result)
        }
        PromiseKit.when(fulfilled: arr).then{ results in
            self.calculateTime() 
        }
    }
    func calculateTime(){
        let finish = Date().timeIntervalSince(start)// - start
        print("Time of work promiseKit: ", finish)
    }
    func displayMessage(str: String?) -> Promise<String>{
        return Promise<String>{fulfill, reject in
            if str != nil{
                let message = str!
                sleep(UInt32(0.1)) // Imitation of asynchrony
                print(message)
                fulfill(message)
            } else{
                let error = ErrorType()
                reject(error)
            }
            
        }
    }

}

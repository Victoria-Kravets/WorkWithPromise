//
//  UsingPromiseWithBlueBird.swift
//  WorkWithPromise
//
//  Created by Viktoria on 8/7/17.
//  Copyright © 2017 Viktoria. All rights reserved.
//

import Foundation
import Bluebird
class UsingPromiseWithBlueBird{
    
    let start = Date()
    
    func usePromise(){
        let str = "Start of woking Bluebird"
        var arr = [Promise<String>]()
        let result = displayMessage(str: str)
        for count in 0...1000000{
            arr.append(result)
        }
        all(arr).then{ result in
            self.calculateTime(message: result[0]) 
        }
        
    }
    func calculateTime(message: String){
        let finish = Date().timeIntervalSince(start)// - start
        print("Time of work Bluebird: ", finish)
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

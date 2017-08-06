//
//  ViewController.swift
//  WorkWithPromise
//
//  Created by Viktoria on 8/3/17.
//  Copyright © 2017 Viktoria. All rights reserved.
//

import UIKit
//import PromiseKit
import Bluebird

class ViewController: UIViewController {

    var count = 0
    let start = Date().timeIntervalSinceNow
    var arrayOfPromise = [Promise<String>].self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let str = "undestanding promiseKit"
        var arr = [Promise<String>]()
        let result = displayMessage(str: str)
        for count in 0...1000000{
            arr.append(result)
        }
        //Bluebird  //
        all(arr).then{ result in
            self.calculateTime() // 2,02c, 28,4Mb, //with sleep() time: 9,53 c, 24,3 Mb
        }
        
        //PromiseKit:
//        PromiseKit.when(fulfilled: arr).then{ results in
//           self.calculateTime() //with sleep() time: 9,53 c, 348,1 // without sleep(): 2,02c, 342,4 Mb
//        }
   
        
    }
    func calculateTime(){
        let finish = Date().timeIntervalSinceNow - start
        print(finish)
    }
    func displayMessage(str: String?) -> Promise<String>{
        return Promise<String>{fulfill, reject in
            if str != nil{
               let message = "Success " + str!
                sleep(UInt32(0.1))
                print(message)
                fulfill(message)
            } else{
                let error = ErrorType()
                reject(error)
            }
            
        }
    }
    
}

struct ErrorType: Error {
    var errorMessage = "Error"
}

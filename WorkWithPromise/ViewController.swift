//
//  ViewController.swift
//  WorkWithPromise
//
//  Created by Viktoria on 8/3/17.
//  Copyright © 2017 Viktoria. All rights reserved.
//

import UIKit
import PromiseKit
import Bluebird

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let promisekit = UsingPromiseWithPromisKit()
        let bluebird = UsingPromiseWithBlueBird()
        promisekit.usePromise() // 14,24c
        bluebird.usePromise() // 15,39c
        
    }

}

struct ErrorType: Error {
    var errorMessage = "Error"
}

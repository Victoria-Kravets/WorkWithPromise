# Promise

[![CI Status](https://img.shields.io/travis/movinpixel/Promise.svg?style=flat)](https://travis-ci.org/movinpixel/Promise)
[![Version](https://img.shields.io/cocoapods/v/Promise.svg?style=flat)](http://cocoapods.org/pods/Promise)
[![License](https://img.shields.io/cocoapods/l/Promise.svg?style=flat)](http://cocoapods.org/pods/Promise)
[![Platform](https://img.shields.io/cocoapods/p/Promise.svg?style=flat)](http://cocoapods.org/pods/Promise)

Promise is a very lightweight and simple to use object that allows you to run code asynchronously, 
and get the result whenever and anywhere your needs fit or when you wish. Promise is thread-safe.

## Usage
Promise is designed to hold and run immediately a block of code. You always start a Promise by using .run() in many ways. For example:
```
Promise.run {
    // here goes some asynchronous code.
}
```

If you want to use this promise somewhere else in the future, for example for taking the result, that could be like that:
```
let myPromise = Promise.run {
    //some method that returns 3
    return 3
}

...
// somewhere in the future

var myPromiseResult = 0
if myPromise.isCompleted {
    myPromiseResult = myPromise.result as! Int
}
```

You can also provide an error handler for the Promise:
```
Promise.run(task: {() throws -> Void in
    // some meaningful code that might throw an error
}, errorHandler: {(error) -> Void in
    // your own error handler
})
```
The above error handler might not be too useful if you prefer to use the swift way of handling errors, for example by using do...catch inside the block itself.
However, it shows very powerful in the next sections.

As a great part of the Promise flexibility, there comes the magic of chaining tasks. They can depend one upon the other.
You chain them by using .then():
```
Promise.run {
    // some important task that returns "lala lones"
    return "lala lones"
}.then {(previousPromiseResult: Any?) -> Void in
    // previousPromiseResult contains the value "lala lones" that came from the previous Promise.
    // you can extract it by many Swift ways, for example:
    let importantString = previousPromiseResult as! String
    ...
    // some important use for the importantString
}.then {
    // notice that the previous Promise doesn't return anything. As so, this block doesn't receive
    // any parameter. In fact, you can also use the previousPromiseResult overload, however the
    // value passed to this parameter is an object of type Void. You can't do anything meaningful
    // with Void.
}
```

You can also handle errors at any point in the Promise chain. All blocks are throwable, so you can safely use try or throw your own exceptions
```
Promise.run {
    // some meaningful code
}.then {
    try someMeaningfulMethod() //let's say this method threw an error
}.then {
    // some meaningful code. This code won't be executed because the
    // previous 'Promise' threw an error.
}.then({
    // some meaningful code. This code won't be executed because the
    // previous 'Promise' threw an error.
}, errorHandler: { (error) throws -> Void in
    // the 'error' parameter contains the error thrown at the second Promise.
    // notice that this block is also throwable, which means that you if you don't want
    // to make this the end, you can rethrow the error, or forward another error if you will.
    // the error that this method throws will continue down the chain in the same way 
    // that .then() does.


    // let's say that the error was fully handled here
}).then {
    // as you can see, you can continue the chain even if there was an error handler before.
    // this method WILL be executed, because the previous Promise contained the 'errorHandler'
    // which fully handled the error.
}.then({
    // some meaningful code
}, errorHandler: {(error) -> Void in
    // another last error handler.
    // if you don't provide an error handler and an error is thrown, the error is
    // simply discarded and the following Promises after the error are not executed.
})
```

Finally, you can execute many Promises concurrently. Actually, every Promise that you intantiate will already run concurrently,
but you can know when all of the desired Promises have finished with the use of .when(). And, of course, you can also have an `errorHandler`.
```
let promise1 = Promise.run {
    // some asynchronous and concurrent task.
}

let promise2 = Promise.run {
    // some asynchronous and concurrent task.
    return 3 // a dummy value just for representation
}.then {(previousPromiseReturn: Any?) -> Void in
    // some asynchronous task, but serial with the previous chained 'Promise'
    // notice that variable 'promise2' refers to THIS Promise. Equality opertor
    // always to refers to the last promise in the chain.
}

let promise3 = Promise.run {
    // another asynchronous and concurrent task.
}

Promise.when([promise1, promise2, promise3], errorHandler: {(error) -> Void in
    // some block of code that will handle the error.
})
```

For the purpose of giving you more control, you can know when a Promise already has a result available by consulting the `result` property.
If `result` is nil, the Promise hasn't yet a result available.
Alternatively, you can also consult the boolean `isCompleted` and `hasErrors` methods to check whether the Promise is still running.
In case any of them are true, the Promise is already stopped and, as Promises can't be reused, this Promise can be discarded.
However, as using these three properties manually is more error-prone, their use is discouraged.

## Requirements

It can run at any operation system that is programable with Swift. This library is for Swift programming language only.

## Installation

Promise is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Promise"
```

## Author

Movinpixel, info@movinpixel.com
We are open for any suggestions! Please send a pull request, or alternatively you can email the suggestion to julio@movinpixel.com

## License

Promise is available under the BSD license. See the LICENSE file for more info.

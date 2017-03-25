
import UIKit

let anArray = ["1", "2", "3", "4", "5", "c"]

if anArray.contains(where: { $0 == "5" }) {
    print("hi!")
} else {
    print("not found")
}


class Foo {
    var fooVar = false {
        didSet { print("\(oldValue) --> \(fooVar)") }
    }
}

let myFoo = Foo()

myFoo.fooVar = true
myFoo.fooVar = true
myFoo.fooVar = !myFoo.fooVar
let temp = myFoo.fooVar
myFoo.fooVar = temp

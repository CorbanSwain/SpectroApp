
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


var foo = [2,1,2,5,2, 2,2,2,2]
let tenDigFoo = ""
for i in 0..<10 {
    if (10 - i) > foo.count {
        print(0, terminator: "")
    } else {
        print(foo[i - (10 - foo.count)], terminator: "")
    }
}
print()
print("||||||||||")
print("0123456789")

let uuid1 = UUID(uuidString: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")

let uuid2 = UUID(uuidString: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")

if uuid1 == uuid2 { print("SAMEE!!!!") }






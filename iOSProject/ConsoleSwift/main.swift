//
//  main.swift
//  ConsoleSwift
//
//  Created by chen liang on 2021/4/8.
//

import Foundation

print("Hello, World!")

class A{
    weak var b:B?
    deinit {
        print("A deinit")
    }
}

class B {
    var a:A?
    deinit {
        print("B deinit")
    }
}

do {
    var a = A()
    var b = B()
    a.b = b
    b.a = a
    
    a.b = nil
}

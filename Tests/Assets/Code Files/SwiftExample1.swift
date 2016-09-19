//
//  SwiftExample1.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 03.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

class SwiftExample1 {
    
    func exampleFunction1() {
        
        NSLocalizedString("TestKey1", comment: "Comment for TestKey1")
        String(format: NSLocalizedString("%@ and %.2f", comment: ""), "SomeString", 25.7528938)
        NSLocalizedString("test.key-one", comment: "Comment for TestKey1")
        NSLocalizedString("test.key-two", comment: "Comment for TestKey1")
        NSLocalizedString("task.key", comment: "Comment for TestKey1")
        NSLocalizedString("abc.key", comment: "Comment for TestKey1")
        NSLocalizedString("ugh", comment: "Comment for TestKey1")
        NSLocalizedString("aaa", comment: "Comment for TestKey1")
    }
    
}

class SwiftExample2 {
    func exampleFunction2() {
        NSLocalizedString("taa", comment: "Comment for TestKey1")
    }
}

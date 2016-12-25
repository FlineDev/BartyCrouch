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

        let s1 = NSLocalizedString("test.multiline_comment", comment: "test comment 1")
        let s2 = NSLocalizedString("test.multiline_comment", comment: "test comment 2")
    }
}

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
        BCLocalizedString("TestKey1", comment: "Comment for TestKey1")
        String(format: BCLocalizedString("%@ and %.2f", comment: ""), "SomeString", 25.752_893_8)

        let s1 = BCLocalizedString("test.multiline_comment", comment: "test comment 1")
        let s2 = BCLocalizedString("test.multiline_comment", comment: "test comment 2")

        BCLocalizedString("test.brackets_comment", comment: "(test comment with brackets)")
    }
}

//
//  SwiftExample2.swift
//  BartyCrouch
//
//  Created by Cihat Gündüz on 03.05.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

import Foundation

class SwiftExample2 {
    func exampleFunction2() {
        BCLocalizedString("TestKey2", comment: "Comment for TestKey1")
        String(format: BCLocalizedString("%010d and %03.f", comment: ""), 25, 89.5)
        String.localizableStringWithFormat(BCLocalizedString("%d ignore(s)", comment: "Ignoring stringsdict key #bc-ignore!"), 25)
    }
}

//
//  SwiftExampleMultipleTables.swift
//  BartyCrouch
//
//  Created by Max Bothe on 16.09.17.
//  Copyright © 2017 Flinesoft. All rights reserved.
//

import Foundation

class SwiftExampleMultipleTables {
    func exampleFunction() {
        NSLocalizedString("test.defaultTableName", comment: "test comment in default table name")
        NSLocalizedString("test.customTableName", tableName: "CustomName", comment: "test comment in custom table name")
    }
}

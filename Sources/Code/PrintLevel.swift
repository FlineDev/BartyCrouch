//
//  Created by Cihat Gündüz on 12.03.18.
//  Copyright © 2018 Flinesoft. All rights reserved.
//

import Cocoa

enum PrintLevel {
    case success
    case info
    case warning
    case error
}

func print(_ message: String, level: PrintLevel) {
    switch level {
    case .success:
        print("✅", "Success!".lightGreen, message.lightGreen)

    case .info:
        print("ℹ️", message.lightBlue)

    case .warning:
        print("⚠️", "Warning!".yellow, message.yellow)

    case .error:
        print("❌", "Error!".lightRed, message.lightRed)
    }
}

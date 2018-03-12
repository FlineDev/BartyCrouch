//
//  Created by Cihat Gündüz on 12.03.18.
//  Copyright © 2018 Flinesoft. All rights reserved.
//

import Cocoa

enum PrintLevel {
    case info
    case warning
    case error
}

func print(_ message: String, level: PrintLevel) {
    switch level {
    case .info:
        print("ℹ️ ", message.lightBlue)

    case .warning:
        print("⚠️ Warning!", message.yellow)

    case .error:
        print("❌ Error!", message.red)
    }
}

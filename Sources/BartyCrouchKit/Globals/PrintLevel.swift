//  Created by Cihat Gündüz on 12.03.18.

import CLISpinner
import Cocoa
import Rainbow

enum PrintLevel {
    case success
    case info
    case warning
    case error

    var color: Color {
        switch self {
        case .success:
            return Color.lightGreen

        case .info:
            return Color.lightBlue

        case .warning:
            return Color.yellow

        case .error:
            return Color.lightRed
        }
    }
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

func performWithSpinner(_ message: String, level: PrintLevel = .info, pattern: CLISpinner.Pattern = .dots, _ closure: () throws -> Void) rethrows {
    let spinner = Spinner(pattern: pattern, text: message, color: level.color)
    spinner.start()
    try closure()
    spinner.stopAndClear()
    spinner.unhideCursor()
}

func measure<ResultType>(task: String, _ closure: () throws -> ResultType) rethrows -> ResultType {
    let startDate = Date()
    let result = try closure()

    let passedTimeInterval = Date().timeIntervalSince(startDate)
    guard passedTimeInterval > 0.1 else { return result } // do not print fast enough tasks

    let passedTimeIntervalNum = NSNumber(value: passedTimeInterval)
    let measureTimeFormatter = NumberFormatter()
    measureTimeFormatter.maximumFractionDigits = 3

    print("Task '\(task)' took \(measureTimeFormatter.string(from: passedTimeIntervalNum)!) seconds.")
    return result
}

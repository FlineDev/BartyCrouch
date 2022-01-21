// swiftlint:disable cyclomatic_complexity file_types_order

import Foundation
import Rainbow

/// The print level type.
enum PrintLevel {
  /// Print success information.
  case success

  /// Print (potentially) long data or less interesting information. Only printed if tool executed in vebose mode.
  case verbose

  /// Print any kind of information potentially interesting to users.
  case info

  /// Print information that might potentially be problematic.
  case warning

  /// Print information that probably is problematic.
  case error

  var color: Color {
    switch self {
    case .success:
      return Color.lightGreen

    case .verbose:
      return Color.lightCyan

    case .info:
      return Color.lightBlue

    case .warning:
      return Color.yellow

    case .error:
      return Color.red
    }
  }
}

/// The output format type.
enum OutputFormatTarget {
  /// Output is targeted to a console to be read by developers.
  case human

  /// Output is targeted to Xcode. Native support for Xcode Warnings & Errors.
  case xcode
}

/// Prints a message to command line with proper formatting based on level, source & output target.
///
/// - Parameters:
///   - message: The message to be printed. Don't include `Error!`, `Warning!` or similar information at the beginning.
///   - level: The level of the print statement.
///   - file: The file this print statement refers to. Used for showing errors/warnings within Xcode if run as script phase.
///   - line: The line within the file this print statement refers to. Used for showing errors/warnings within Xcode if run as script phase.
func print(_ message: String, level: PrintLevel, file: String? = nil, line: Int? = nil) {
  if TestHelper.shared.isStartedByUnitTests {
    TestHelper.shared.printOutputs.append((message, level, file, line))
    return
  }

  if GlobalOptions.failOnWarnings.value && level == .warning {
    CommandExecution.current.didPrintWarning = true
  }

  if GlobalOptions.xcodeOutput.value {
    xcodePrint(message, level: level, file: file, line: line)
  }
  else {
    humanPrint(message, level: level, file: file, line: line)
  }
}

private func humanPrint(_ message: String, level: PrintLevel, file: String? = nil, line: Int? = nil) {
  let location = locationInfo(file: file, line: line)?
    .replacingOccurrences(of: FileManager.default.currentDirectoryPath, with: ".")
  let message = location != nil ? [location!, message].joined(separator: " ") : message

  switch level {
  case .success:
    print(currentDateTime(), "✅ ", message.lightGreen)

  case .verbose:
    if GlobalOptions.verbose.value {
      print(currentDateTime(), "🗣 ", message.lightCyan)
    }

  case .info:
    print(currentDateTime(), "ℹ️ ", message.lightBlue)

  case .warning:
    print(currentDateTime(), "⚠️ ", message.yellow)

  case .error:
    print(currentDateTime(), "❌ ", message.lightRed)
  }
}

private func currentDateTime() -> String {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
  let dateTime = dateFormatter.string(from: Date())
  return "\(dateTime):"
}

private func xcodePrint(_ message: String, level: PrintLevel, file: String? = nil, line: Int? = nil) {
  let location = locationInfo(file: file, line: line)

  switch level {
  case .success:
    if let location = location {
      print(location, "success: BartyCrouch: ", message)
    }
    else {
      print("success: BartyCrouch: ", message)
    }

  case .verbose:
    if GlobalOptions.verbose.value {
      if let location = location {
        print(location, "verbose: BartyCrouch: ", message)
      }
      else {
        print("verbose: BartyCrouch: ", message)
      }
    }

  case .info:
    if let location = location {
      print(location, "info: BartyCrouch: ", message)
    }
    else {
      print("info: BartyCrouch: ", message)
    }

  case .warning:
    if let location = location {
      print(location, "warning: BartyCrouch: ", message)
    }
    else {
      print("warning: BartyCrouch: ", message)
    }

  case .error:
    if let location = location {
      print(location, "error: BartyCrouch: ", message)
    }
    else {
      print("error: BartyCrouch: ", message)
    }
  }
}

private func locationInfo(file: String?, line: Int?) -> String? {
  guard let file = file else { return nil }
  guard let line = line else { return "\(file): " }
  return "\(file):\(line): "
}

private let dispatchGroup = DispatchGroup()

func measure<ResultType>(task: String, _ closure: () throws -> ResultType) rethrows -> ResultType {
  let startDate = Date()
  print("Starting Task '\(task)' ...")

  let result = try closure()

  let passedTimeInterval = Date().timeIntervalSince(startDate)
  guard passedTimeInterval > 0.1 else { return result }  // do not print fast enough tasks

  let passedTimeIntervalNum = NSNumber(value: passedTimeInterval)
  let measureTimeFormatter = NumberFormatter()
  measureTimeFormatter.minimumIntegerDigits = 1
  measureTimeFormatter.maximumFractionDigits = 3
  measureTimeFormatter.locale = Locale(identifier: "en")

  print("Task '\(task)' took \(measureTimeFormatter.string(from: passedTimeIntervalNum)!) seconds.")
  return result
}

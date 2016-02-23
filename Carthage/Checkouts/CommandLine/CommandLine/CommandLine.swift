/*
 * CommandLine.swift
 * Copyright (c) 2014 Ben Gollmer.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* Required for setlocale(3) */
@exported import Darwin

let ShortOptionPrefix = "-"
let LongOptionPrefix = "--"

/* Stop parsing arguments when an ArgumentStopper (--) is detected. This is a GNU getopt
 * convention; cf. https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html
 */
let ArgumentStopper = "--"

/* Allow arguments to be attached to flags when separated by this character.
 * --flag=argument is equivalent to --flag argument
 */
let ArgumentAttacher: Character = "="

/* An output stream to stderr; used by CommandLine.printUsage(). */
private struct StderrOutputStream: OutputStreamType {
  static let stream = StderrOutputStream()
  func write(s: String) {
    fputs(s, stderr)
  }
}

/**
 * The CommandLine class implements a command-line interface for your app.
 * 
 * To use it, define one or more Options (see Option.swift) and add them to your
 * CommandLine object, then invoke `parse()`. Each Option object will be populated with
 * the value given by the user.
 *
 * If any required options are missing or if an invalid value is found, `parse()` will throw
 * a `ParseError`. You can then call `printUsage()` to output an automatically-generated usage
 * message.
 */
public class CommandLine {
  private var _arguments: [String]
  private var _options: [Option] = [Option]()
  
  /** A ParseError is thrown if the `parse()` method fails. */
  public enum ParseError: ErrorType, CustomStringConvertible {
    /** Thrown if an unrecognized argument is passed to `parse()` in strict mode */
    case InvalidArgument(String)

    /** Thrown if the value for an Option is invalid (e.g. a string is passed to an IntOption) */
    case InvalidValueForOption(Option, [String])
    
    /** Thrown if an Option with required: true is missing */
    case MissingRequiredOptions([Option])
    
    public var description: String {
      switch self {
      case let .InvalidArgument(arg):
        return "Invalid argument: \(arg)"
      case let .InvalidValueForOption(opt, vals):
        let vs = vals.joinWithSeparator(", ")
        return "Invalid value(s) for option \(opt.flagDescription): \(vs)"
      case let .MissingRequiredOptions(opts):
        return "Missing required options: \(opts.map { return $0.flagDescription })"
      }
    }
  }
  
  /**
   * Initializes a CommandLine object.
   *
   * - parameter arguments: Arguments to parse. If omitted, the arguments passed to the app
   *   on the command line will automatically be used.
   *
   * - returns: An initalized CommandLine object.
   */
  public init(arguments: [String] = Process.arguments) {
    self._arguments = arguments
    
    /* Initialize locale settings from the environment */
    setlocale(LC_ALL, "")
  }
  
  /* Returns all argument values from flagIndex to the next flag or the end of the argument array. */
  private func _getFlagValues(flagIndex: Int) -> [String] {
    var args: [String] = [String]()
    var skipFlagChecks = false
    
    /* Grab attached arg, if any */
    var attachedArg = _arguments[flagIndex].splitByCharacter(ArgumentAttacher, maxSplits: 1)
    if attachedArg.count > 1 {
      args.append(attachedArg[1])
    }
    
    for var i = flagIndex + 1; i < _arguments.count; i++ {
      if !skipFlagChecks {
        if _arguments[i] == ArgumentStopper {
          skipFlagChecks = true
          continue
        }
        
        if _arguments[i].hasPrefix(ShortOptionPrefix) && Int(_arguments[i]) == nil &&
          _arguments[i].toDouble() == nil {
          break
        }
      }
    
      args.append(_arguments[i])
    }
    
    return args
  }
  
  /**
   * Adds an Option to the command line.
   *
   * - parameter option: The option to add.
   */
  public func addOption(option: Option) {
    _options.append(option)
  }
  
  /**
   * Adds one or more Options to the command line.
   *
   * - parameter options: An array containing the options to add.
   */
  public func addOptions(options: [Option]) {
    _options += options
  }
  
  /**
   * Adds one or more Options to the command line.
   *
   * - parameter options: The options to add.
   */
  public func addOptions(options: Option...) {
    _options += options
  }
  
  /**
   * Sets the command line Options. Any existing options will be overwritten.
   *
   * - parameter options: An array containing the options to set.
   */
  public func setOptions(options: [Option]) {
    _options = options
  }
  
  /**
   * Sets the command line Options. Any existing options will be overwritten.
   *
   * - parameter options: The options to set.
   */
  public func setOptions(options: Option...) {
    _options = options
  }
  
  /**
   * Parses command-line arguments into their matching Option values. Throws `ParseError` if
   * argument parsing fails.
   *
   * - parameter strict: Fail if any unrecognized arguments are present (default: false).
   */
  public func parse(strict: Bool = false) throws {
    for (idx, arg) in _arguments.enumerate() {
      if arg == ArgumentStopper {
        break
      }
      
      if !arg.hasPrefix(ShortOptionPrefix) {
        continue
      }
      
      let skipChars = arg.hasPrefix(LongOptionPrefix) ?
        LongOptionPrefix.characters.count : ShortOptionPrefix.characters.count
      let flagWithArg = arg[Range(start: arg.startIndex.advancedBy(skipChars), end: arg.endIndex)]
      
      /* The argument contained nothing but ShortOptionPrefix or LongOptionPrefix */
      if flagWithArg.isEmpty {
        continue
      }
      
      /* Remove attached argument from flag */
      let flag = flagWithArg.splitByCharacter(ArgumentAttacher, maxSplits: 1)[0]
      
      var flagMatched = false
      for option in _options {
        if option.flagMatch(flag) {
          let vals = self._getFlagValues(idx)
          guard option.setValue(vals) else {
            throw ParseError.InvalidValueForOption(option, vals)
          }
          
          flagMatched = true
          break
        }
      }
      
      /* Flags that do not take any arguments can be concatenated */
      let flagLength = flag.characters.count
      if !flagMatched && !arg.hasPrefix(LongOptionPrefix) {
        for (i, c) in flag.characters.enumerate() {
          for option in _options {
            if option.flagMatch(String(c)) {
              /* Values are allowed at the end of the concatenated flags, e.g.
               * -xvf <file1> <file2>
               */
              let vals = (i == flagLength - 1) ? self._getFlagValues(idx) : [String]()
              guard option.setValue(vals) else {
                throw ParseError.InvalidValueForOption(option, vals)
              }
              
              flagMatched = true
              break
            }
          }
        }
      }

      /* Invalid flag */
      guard !strict || flagMatched else {
        throw ParseError.InvalidArgument(arg)
      }
    }

    /* Check to see if any required options were not matched */
    let missingOptions = _options.filter { $0.required && !$0.wasSet }
    guard missingOptions.count == 0 else {
      throw ParseError.MissingRequiredOptions(missingOptions)
    }
  }
  
  /* printUsage() is generic for OutputStreamType because the Swift compiler crashes
   * on inout protocol function parameters in Xcode 7 beta 1 (rdar://21372694).
   */
  
  /**
   * Prints a usage message.
   * 
   * - parameter to: An OutputStreamType to write the error message to.
   */
  public func printUsage<TargetStream: OutputStreamType>(inout to: TargetStream) {
    let name = _arguments[0]
    
    var flagWidth = 0
    for opt in _options {
      flagWidth = max(flagWidth, "  \(opt.flagDescription):".characters.count)
    }

    print("Usage: \(name) [options]", toStream: &to)
    for opt in _options {
      let flags = "  \(opt.flagDescription):".paddedToWidth(flagWidth)
      print("\(flags)\n      \(opt.helpMessage)", toStream: &to)
    }
  }
  
  /**
   * Prints a usage message.
   *
   * - parameter error: An error thrown from `parse()`. A description of the error
   *   (e.g. "Missing required option --extract") will be printed before the usage message.
   * - parameter to: An OutputStreamType to write the error message to.
   */
  public func printUsage<TargetStream: OutputStreamType>(error: ErrorType, inout to: TargetStream) {
    print("\(error)\n", toStream: &to)
    printUsage(&to)
  }
  
  /**
   * Prints a usage message.
   *
   * - parameter error: An error thrown from `parse()`. A description of the error
   *   (e.g. "Missing required option --extract") will be printed before the usage message.
   */
  public func printUsage(error: ErrorType) {
    var out = StderrOutputStream.stream
    printUsage(error, to: &out)
  }
  
  /**
   * Prints a usage message.
   */
  public func printUsage() {
    var out = StderrOutputStream.stream
    printUsage(&out)
  }
}

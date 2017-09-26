# CommandLineKit [![Build Status](https://travis-ci.org/jatoben/CommandLine.svg?branch=master)](https://travis-ci.org/jatoben/CommandLine)

A pure Swift library for creating command-line interfaces.

*Note: CommandLineKit `master` requires Xcode 8 / Swift 3.0. If you're using older versions of Swift, please check out the [earlier releases](https://github.com/jatoben/CommandLine/releases).*

## Usage

CommandLine aims to have a simple and self-explanatory API.

```swift
import CommandLineKit

let cli = CommandLineKit.CommandLine()

let filePath = StringOption(shortFlag: "f", longFlag: "file", required: true,
  helpMessage: "Path to the output file.")
let compress = BoolOption(shortFlag: "c", longFlag: "compress",
  helpMessage: "Use data compression.")
let help = BoolOption(shortFlag: "h", longFlag: "help",
  helpMessage: "Prints a help message.")
let verbosity = CounterOption(shortFlag: "v", longFlag: "verbose",
  helpMessage: "Print verbose messages. Specify multiple times to increase verbosity.")

cli.addOptions(filePath, compress, help, verbosity)

do {
  try cli.parse()
} catch {
  cli.printUsage(error)
  exit(EX_USAGE)
}

print("File path is \(filePath.value!)")
print("Compress is \(compress.value)")
print("Verbosity is \(verbosity.value)")
```

See `Option.swift` for additional Option types.

To use CommandLineKit in your project, add it to your workspace, then add CommandLineKit.framework to the __Build Phases / Link Binary With Libraries__ setting of your target.

If you are building a command-line tool and need to embed this and other frameworks to it, follow the steps in http://colemancda.github.io/2015/02/12/embedded-swift-frameworks-osx-command-line-tools/ to link Swift frameworks to your command-line tool.

If you are building a standalone command-line tool, you'll need to add the CommandLineKit source files directly to your target, because Xcode [can't yet build static libraries that contain Swift code](https://github.com/ksm/SwiftInFlux#static-libraries).


## Features

### Automatically generated usage messages

```
Usage: example [options]
  -f, --file:    
      Path to the output file.
  -c, --compress:
      Use data compression.
  -h, --help:    
      Prints a help message.
  -v, --verbose:
      Print verbose messages. Specify multiple times to increase verbosity.
```

You can fully customize the usage message by supplying a `formatOutput` function. For example, [Rainbow](https://github.com/onevcat/Rainbow) provides a handy way to generate colorized output:

```swift
import Rainbow

cli.formatOutput = { s, type in
  var str: String
  switch(type) {
  case .Error:
    str = s.red.bold
  case .OptionFlag:
    str = s.green.underline
  case .OptionHelp:
    str = s.blue
  default:
    str = s
  }

  return cli.defaultFormat(str, type: type)
}
```

![](https://cloud.githubusercontent.com/assets/318083/12108437/1e3ec25c-b335-11e5-9cc9-d45ad3ab3dc7.png)

### Supports all common flag styles

These command-lines are equivalent:

```bash
$ ./example -c -v -f /path/to/file
$ ./example -cvf /path/to/file
$ ./example -c --verbose --file /path/to/file
$ ./example -cv --file /path/to/file
$ ./example --compress -v --file=/path/to/file
```

Option processing can be stopped with '--', [as in getopt(3)](https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html).

### Intelligent handling of negative int & float arguments

This will pass negative 42 to the int option, and negative 3.1419 to the float option:

```bash
$ ./example2 -i -42 --float -3.1419
```

### Locale-aware float parsing

Floats will be handled correctly when in a locale that uses an alternate decimal point character:

```bash
$ LC_NUMERIC=sv_SE.UTF-8 ./example2 --float 3,1419
```

### Type-safe Enum options

```swift
enum Operation: String {
  case create  = "c"
  case extract = "x"
  case list    = "l"
  case verify  = "v"
}

let cli = CommandLineKit.CommandLine()
let op = EnumOption<Operation>(shortFlag: "o", longFlag: "operation", required: true,
  helpMessage: "File operation - c for create, x for extract, l for list, or v for verify.")
cli.setOptions(op)

do {
  try cli.parse()
} catch {
  cli.printUsage(error)
  exit(EX_USAGE)
}

switch op.value {
  case Operation.Create:
    // Create file

  case Operation.Extract:
    // Extract file

  // Remainder of cases
}
```

Note: Enums must be initalizable from a String value.

### Fully emoji-compliant

```bash
$ ./example3 -👍 --👻
```

*(please don't actually do this)*

License
-------
Copyright (c) 2014 Ben Gollmer.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

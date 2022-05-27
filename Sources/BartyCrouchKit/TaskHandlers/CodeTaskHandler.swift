import BartyCrouchConfiguration
import Foundation

struct CodeTaskHandler {
  let options: CodeOptions
}

extension CodeTaskHandler: TaskHandler {
  func perform() {
    measure(task: "Update Code") {
      mungo.do {
        CommandLineActor()
          .actOnCode(
            paths: options.codePaths,
            subpathsToIgnore: options.subpathsToIgnore,
            override: false,
            verbose: GlobalOptions.verbose.value,
            localizables: options.localizablePaths,
            defaultToKeys: options.defaultToKeys,
            additive: options.additive,
            overrideComments: false,
            unstripped: options.unstripped,
            customFunction: options.customFunction,
            customLocalizableName: options.customLocalizableName,
            usePlistArguments: options.plistArguments,
            ignoreKeys: options.ignoreKeys
          )
      }
    }
  }
}

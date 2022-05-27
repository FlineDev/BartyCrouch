import BartyCrouchConfiguration
import Foundation

struct NormalizeTaskHandler {
  let options: NormalizeOptions
}

extension NormalizeTaskHandler: TaskHandler {
  func perform() {
    measure(task: "Normalize") {
      mungo.do {
        CommandLineActor()
          .actOnNormalize(
            paths: options.paths,
            subpathsToIgnore: options.subpathsToIgnore,
            override: false,
            verbose: GlobalOptions.verbose.value,
            locale: options.sourceLocale,
            sortByKeys: options.sortByKeys,
            harmonizeWithSource: options.harmonizeWithSource,
            separateWithEmptyLine: options.separateWithEmptyLine
          )
      }
    }
  }
}

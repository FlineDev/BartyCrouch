import BartyCrouchConfiguration
import Foundation

struct LintTaskHandler {
  let options: LintOptions
}

extension LintTaskHandler: TaskHandler {
  func perform() {
    measure(task: "Lint") {
      mungo.do {
        CommandLineActor()
          .actOnLint(
            paths: options.paths,
            subpathsToIgnore: options.subpathsToIgnore,
            duplicateKeys: options.duplicateKeys,
            emptyValues: options.emptyValues
          )
      }
    }
  }
}

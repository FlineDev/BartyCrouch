import Foundation
import BartyCrouchConfiguration

struct LintTaskHandler {
  let options: LintOptions

  init(
    options: LintOptions
  ) {
    self.options = options
  }
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

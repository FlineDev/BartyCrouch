import BartyCrouchConfiguration
import Foundation

struct TranslateTaskHandler {
  let options: TranslateOptions
}

extension TranslateTaskHandler: TaskHandler {
  func perform() {
    // TODO: add support for multiple APIs (currently not in the parameter list of actOnTranslate)

    measure(task: "Translate") {
      mungo.do {
        CommandLineActor()
          .actOnTranslate(
            paths: options.paths,
            subpathsToIgnore: options.subpathsToIgnore,
            override: false,
            verbose: GlobalOptions.verbose.value,
            secret: options.secret,
            locale: options.sourceLocale,
            separateWithEmptyLine: self.options.separateWithEmptyLine
          )
      }
    }
  }
}

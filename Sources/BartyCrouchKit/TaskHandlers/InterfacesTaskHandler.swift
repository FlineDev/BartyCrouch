import BartyCrouchConfiguration
import Foundation

struct InterfacesTaskHandler {
  let options: InterfacesOptions
}

extension InterfacesTaskHandler: TaskHandler {
  func perform() {
    measure(task: "Update Interfaces") {
      mungo.do {
        CommandLineActor()
          .actOnInterfaces(
            paths: options.paths,
            subpathsToIgnore: options.subpathsToIgnore,
            override: false,
            verbose: GlobalOptions.verbose.value,
            defaultToBase: options.defaultToBase,
            unstripped: options.unstripped,
            ignoreEmptyStrings: options.ignoreEmptyStrings,
            ignoreKeys: options.ignoreKeys
          )
      }
    }
  }
}

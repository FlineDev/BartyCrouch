import BartyCrouchConfiguration
import Foundation

struct InitTaskHandler {
  /* for extension purposes only */
}

extension InitTaskHandler: TaskHandler {
  func perform() {
    createDefaultConfigFile()
  }

  func createDefaultConfigFile() {
    measure(task: "Default Config Creation") {
      mungo.do {
        let configUrl: URL = Configuration.configUrl

        guard !FileManager.default.fileExists(atPath: configUrl.path) else {
          print("File at path \(configUrl.path) already exists. Skipping creation.", level: .warning)
          return
        }

        let defaultConfiguration: Configuration = try Configuration.makeDefault()
        let configurationContents: String = defaultConfiguration.tomlContents()
        try configurationContents.write(to: configUrl, atomically: true, encoding: .utf8)

        print("Successfully created file \(Configuration.fileName)", level: .success)
      }
    }
  }
}

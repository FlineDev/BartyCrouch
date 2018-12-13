import Foundation


struct InitTaskHandler {}

extension InitTaskHandler: TaskHandler {
    func perform() {
        createDefaultConfigFile()
        createBuildScript()
    }

    func createDefaultConfigFile() {
        measure(task: "Init") {
            performWithSpinner("Init") {
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

    func createBuildScript() {
        // TODO: find xcode project, ask user if multiple are found
        // TODO: search for a build script entry that executes the previously recommended build scripts, replace it with the shorter one
        // TODO: if none is found, add a build script with the new bartycrouch commands (`bartycrouch update` and `bartycrouch lint`)
    }
}

import Foundation

struct CodeTaskHandler {
    let options: CodeOptions

    init(options: CodeOptions) {
        self.options = options
    }
}

extension CodeTaskHandler: TaskHandler {
    func perform() {
        measure(task: "Update Code") {
            mungo.do {
                CommandLineActor().actOnCode(
                    paths: options.codePaths,
                    override: false,
                    verbose: GlobalOptions.verbose.value,
                    localizables: options.localizablePaths,
                    defaultToKeys: options.defaultToKeys,
                    additive: options.additive,
                    overrideComments: false,
                    unstripped: options.unstripped,
                    customFunction: options.customFunction,
                    customLocalizableName: options.customLocalizableName,
                    usePlistArguments: options.plistArguments
                )
            }
        }
    }
}

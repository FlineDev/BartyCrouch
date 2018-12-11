import Foundation

struct CodeTaskHandler {
    let options: CodeOptions

    init(options: CodeOptions) {
        self.options = options
    }
}

extension CodeTaskHandler: TaskHandler {
    func perform() {
        CommandLineActor().actOnCode(
            path: options.codePath,
            override: false,
            verbose: GlobalOptions.verbose.value,
            localizable: options.localizablePath,
            defaultToKeys: options.defaultToKeys,
            additive: options.additive,
            overrideComments: false,
            unstripped: options.unstripped,
            customFunction: options.customFunction,
            customLocalizableName: options.customLocalizableName
        )
    }
}

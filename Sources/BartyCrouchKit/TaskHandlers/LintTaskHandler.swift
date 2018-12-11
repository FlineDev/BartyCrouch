import Foundation

struct LintTaskHandler {
    let options: LintOptions

    init(options: LintOptions) {
        self.options = options
    }
}

extension LintTaskHandler: TaskHandler {
    func perform() {
        CommandLineActor().actOnLint(
            path: options.path,
            duplicateKeys: options.duplicateKeys,
            emptyValues: options.emptyValues
        )
    }
}

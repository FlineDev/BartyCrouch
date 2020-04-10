import Foundation

struct TranslateTaskHandler {
    let options: TranslateOptions

    init(options: TranslateOptions) {
        self.options = options
    }
}

extension TranslateTaskHandler: TaskHandler {
    func perform() {
        // TODO: add support for multiple APIs (currently not in the parameter list of actOnTranslate)

        measure(task: "Translate") {
            mungo.do {
                CommandLineActor().actOnTranslate(
                    paths: options.paths,
                    override: false,
                    verbose: GlobalOptions.verbose.value,
                    secret: options.secret,
                    locale: options.sourceLocale
                )
            }
        }
    }
}

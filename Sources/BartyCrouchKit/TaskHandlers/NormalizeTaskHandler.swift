import Foundation

struct NormalizeTaskHandler {
    let options: NormalizeOptions

    init(options: NormalizeOptions) {
        self.options = options
    }
}

extension NormalizeTaskHandler: TaskHandler {
    func perform() {
        CommandLineActor().actOnNormalize(
            path: options.path,
            override: false,
            verbose: GlobalOptions.verbose.value,
            locale: options.sourceLocale,
            sortByKeys: options.sortByKeys,
            harmonizeWithSource: options.harmonizeWithSource
        )
    }
}

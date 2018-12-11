import Foundation

struct TranslateTaskHandler {
    let options: TranslateOptions

    init(options: TranslateOptions) {
        self.options = options
    }
}

extension TranslateTaskHandler: TaskHandler {
    func perform() {
        // TODO: not yet implemented
    }
}

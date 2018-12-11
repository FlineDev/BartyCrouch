import Foundation

struct LintTaskHandler {
    let options: LintOptions

    init(options: LintOptions) {
        self.options = options
    }
}

extension LintTaskHandler: TaskHandler {
    func perform() {
        // TODO: not yet implemented
    }
}

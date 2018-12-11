import Foundation

struct CodeTaskHandler {
    let options: CodeOptions

    init(options: CodeOptions) {
        self.options = options
    }
}

extension CodeTaskHandler: TaskHandler {
    func perform() {
        // TODO: not yet implemented
    }
}

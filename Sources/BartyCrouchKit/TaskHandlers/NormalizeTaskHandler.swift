import Foundation

struct NormalizeTaskHandler {
    let options: NormalizeOptions

    init(options: NormalizeOptions) {
        self.options = options
    }
}

extension NormalizeTaskHandler: TaskHandler {
    func perform() {
        // TODO: not yet implemented
    }
}

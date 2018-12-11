import Foundation

struct InterfacesTaskHandler {
    let options: InterfacesOptions

    init(options: InterfacesOptions) {
        self.options = options
    }
}

extension InterfacesTaskHandler: TaskHandler {
    func perform() {
        // TODO: not yet implemented
    }
}

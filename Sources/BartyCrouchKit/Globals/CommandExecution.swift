// Created by Cihat Gündüz on 29.01.19.

import Foundation

final class CommandExecution {
    static let current = CommandExecution()

    var didPrintWarning: Bool = false

    func failIfNeeded() {
        if GlobalOptions.failOnWarnings.value && didPrintWarning {
            exit(EXIT_FAILURE)
        }
    }
}

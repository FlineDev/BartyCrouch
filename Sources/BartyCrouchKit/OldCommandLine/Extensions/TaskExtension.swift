//  Created by Christos Koninis on 25/09/2019.

import Foundation
import SwiftCLI

// Task extentions to querry the limitations of the Task's argument list
extension Task {
    // Method to determent if the argument list is to long to pass to new process
    static func isArgumentListTooLong(_ argumentList: [String]) -> Bool {
        // Get maximum length of arguments for a new process (in Bytes) and the maximum count for the list for arguments. See
        // https://www.in-ulm.de/~mascheck/various/argmax/ for more info.
        guard
            let maxArgumentLength = resultForGetconfCommand("expr `getconf ARG_MAX` - `env|wc -c` - `env|wc -l` \\* 4 - 2048"),
            let maxArgumentCount = resultForGetconfCommand("expr `getconf _POSIX_ARG_MAX`")
            else {
            return false
        }

        let argumentListLength = argumentList.joined(separator: " ").utf8.count
        let isArgumentListLengthTooLong = maxArgumentLength < argumentListLength
        let isArgumentListCountTooLong = maxArgumentCount < argumentList.count + ProcessInfo.processInfo.environment.keys.count

        return isArgumentListLengthTooLong || isArgumentListCountTooLong
    }

    private static func resultForGetconfCommand(_ getconfCommand: String) -> Int? {
        guard let commandResult = try? Task.capture(bash: getconfCommand) else { return nil }

        return Int(commandResult.stdout)
    }
}

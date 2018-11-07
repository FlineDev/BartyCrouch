//  Created by Cihat Gündüz on 11.02.16.

import Foundation
import SwiftCLI

/// Sends `ibtool` commands with specified input/output paths to bash.
public final class IBToolCommander {
    // MARK: - Stored Type Properties
    public static let shared = IBToolCommander()

    // MARK: - Instance Methods
    public func export(stringsFileToPath stringsFilePath: String, fromIbFileAtPath ibFilePath: String) throws {
        let arguments = ["--export-strings-file", stringsFilePath, ibFilePath]
        try run("/usr/bin/ibtool", arguments: arguments)
    }
}

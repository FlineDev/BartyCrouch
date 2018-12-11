// Created by Cihat Gündüz on 07.11.18.

import Foundation
import SwiftCLI

public class UpdateCommand: Command {
    // MARK: - Command
    public let name: String = "update"
    public let shortDescription: String = "Update your .strings file contents with the configured tasks (default: interfaces, code, normalize)"

    // MARK: - Initializers
    public init() {}

    // MARK: - Instance Methods
    public func execute() throws {
        let updateOptions = try Configuration.load().updateOptions

        for task in updateOptions.tasks {
            
        }

        print("Command '\(name)' is not yet implemented", level: .info)
    }
}

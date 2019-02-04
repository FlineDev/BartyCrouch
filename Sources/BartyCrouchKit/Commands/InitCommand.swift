// Created by Cihat Gündüz on 13.12.18.

import Foundation
import SwiftCLI

public class InitCommand: Command {
    // MARK: - Command
    public let name: String = "init"
    public let shortDescription: String = "Creates the default configuration file & creates a build script if Xcode project found"

    // MARK: - Initializers
    public init() {}

    // MARK: - Instance Methods
    public func execute() throws {
        InitTaskHandler().perform()
        CommandExecution.current.failIfNeeded()
    }
}

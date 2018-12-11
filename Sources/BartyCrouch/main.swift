//  Created by Cihat Gündüz on 10.02.16.

import BartyCrouchKit
import Foundation
import SwiftCLI

// MARK: - CLI
let cli = CLI(
    name: "bartycrouch",
    version: "4.0.0",
    description: "Incrementally update & translate your Strings files from code or interface files."
)

cli.commands = [UpdateCommand(), LintCommand()]
cli.globalOptions.append(contentsOf: SharedOptions.all)
cli.goAndExit()

//let config = Config.load()
//let targetUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(".bartycrouch.json")
//let data = try JSONEncoder().encode(config)
//try data.write(to: targetUrl)
//print("Did write config to \(targetUrl)")

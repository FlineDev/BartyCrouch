// beak: kareman/SwiftShell @ .upToNextMajor(from: "4.1.2")
// beak: Flinesoft/HandySwift @ .upToNextMajor(from: "2.7.0")

import HandySwift
import Foundation
import SwiftShell

// MARK: - Tasks
/// Installs project dependencies.
public func installDependencies() throws {
    let spmCommand = "swift package resolve"
    print("Installing dependencies via SPM: '\(spmCommand)'")
    try runAndPrint(bash: spmCommand)

    let carthageCommand = "carthage bootstrap --platform macOS --cache-builds"
    print("Installing dependencies via Carthage: '\(carthageCommand)'")
    try runAndPrint(bash: carthageCommand)
}

/// Updates project dependencies.
public func updateDependencies() throws {
    let spmCommand = "swift package update"
    print("Updating dependencies via SPM: '\(spmCommand)'")
    try runAndPrint(bash: spmCommand)

    let carthageCommand = "carthage update --platform macOS --cache-builds"
    print("Updating dependencies via Carthage: '\(carthageCommand)'")
    try runAndPrint(bash: carthageCommand)
}

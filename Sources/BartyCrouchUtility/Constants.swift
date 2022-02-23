import Foundation

/// All constants needed in BartyCrouchKit are collected in one place.
public enum Constants {
  /// These keys can be places in the 'Comment for Localizer' in Interface Builder files to signal that they should be ignored from adding to Strings files.
  public static let defaultIgnoreKeys: [String] = ["#bartycrouch-ignore!", "#bc-ignore!", "#i!"]

  /// Paths to be ignored while searching for code files to consider as sources for new translation keys added to the project.
  public static let defaultSubpathsToIgnore: [String] = [".git", "carthage", "pods", "build", ".build", "docs"]
}

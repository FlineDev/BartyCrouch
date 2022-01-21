import Foundation

/// A helper class for Unit Testing only. Only put data in here when `isStartedByUnitTests` is set to true.
/// Never read other data in framework than that property.
final class TestHelper {
  typealias PrintOutput = (message: String, level: PrintLevel, file: String?, line: Int?)

  static let shared = TestHelper()

  /// Set to `true` within unit tests (in `setup()`). Defaults to `false`.
  var isStartedByUnitTests: Bool = false

  /// Use only in Unit Tests.
  var printOutputs: [PrintOutput] = []

  /// Deletes all data collected until now.
  func reset() {
    printOutputs = []
  }
}

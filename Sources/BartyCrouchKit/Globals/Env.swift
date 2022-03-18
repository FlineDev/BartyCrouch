import Foundation

let env = Env()  // swiftlint:disable:this file_types_order

struct Env {
  fileprivate init() {}

  subscript(key: String) -> String? {
    let env = ProcessInfo.processInfo.environment
    guard env.keys.contains(key) else { return nil }
    return env[key]
  }
}

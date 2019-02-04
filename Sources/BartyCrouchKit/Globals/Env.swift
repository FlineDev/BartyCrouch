// Created by Cihat Gündüz on 08.11.18.

import Foundation

let env = Env()

struct Env {
    fileprivate init() {}

    subscript(key: String) -> String? {
        let env = ProcessInfo.processInfo.environment
        guard env.keys.contains(key) else { return nil }
        return env[key]
    }
}

// Created by Cihat Gündüz on 23.01.19.

import Foundation

extension String {
    func firstCharacterLowercased() -> String {
        let firstCharacter = prefix(1)
        let leftoverString = suffix(from: firstCharacter.endIndex)
        return firstCharacter.lowercased() + leftoverString
    }
}

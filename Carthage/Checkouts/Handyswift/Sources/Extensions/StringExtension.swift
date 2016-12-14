//
//  StringExtension.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 26.12.15.
//  Copyright © 2015 Flinesoft. All rights reserved.
//

import Foundation

public extension String {

    /// Strips all whitespace characters from beginning and end.
    ///
    /// - Returns: The string stripped by whitespace characters from beginning and end.
    public var strip: String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }

    /// Checks if contains any characters other than whitespace characters.
    ///
    /// - Returns: `true` if contains any cahracters other than whitespace characters.
    public var isBlank: Bool {
        return strip.isEmpty
    }

    /// The type of allowed characters.
    ///
    /// - Numeric:          Allow all numbers from 0 to 9.
    /// - Alphabetic:       Allow all alphabetic characters ignoring case.
    /// - AlphaNumeric:     Allow both numbers and alphabetic characters ignoring case.
    /// - AllCharactersIn:  Allow all characters appearing within the specified String.
    public enum AllowedCharacters {
        case numeric
        case alphabetic
        case alphaNumeric
        case allCharactersIn(String)
    }

    /// Create new instance with random numeric/alphabetic/alphanumeric String of given length.
    ///
    /// - Parameters:
    ///   - randommWithLength:      The length of the random String to create.
    ///   - allowedCharactersType:  The allowed characters type, see enum `AllowedCharacters`.
    public init(randomWithLength length: Int, allowedCharactersType: AllowedCharacters) {

        let allowedCharsString: String = {
            switch allowedCharactersType {
            case .numeric:
                return "0123456789"
            case .alphabetic:
                return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
            case .alphaNumeric:
                return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            case .allCharactersIn(let allowedCharactersString):
                return allowedCharactersString
            }
        }()

        self.init(allowedCharsString.characters.sample(size: length)!)

    }

}

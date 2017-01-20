//
//  ColorExtension.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 17.04.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

#if !os(OSX)
    import UIKit

    extension UIColor {
        /// A list of changeable attributes of the UIColor.
        ///
        /// - Red:          The red color part of RGB & alpha.
        /// - Green:        The green color part of RGB & alpha.
        /// - Blue:         The blue color part of RGB & alpha.
        /// - Alpha:        The alpha color part of RGB & alpha / HSB & alpha.
        /// - Hue:          The hue color part of HSB & alpha.
        /// - Saturation:   The saturation color part of HSB & alpha.
        /// - Brightness:   The brightness color part of HSB & alpha.
        ///
        public enum ChangeableAttribute {
            case red, green, blue, hue, saturation, brightness, alpha
        }

        // MARK: - Computed Properties

        /// The HSB & alpha attributes of the `UIColor` instance.
        public var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
            var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) = (0, 0, 0, 0)
            getHue(&(hsba.hue), saturation: &(hsba.saturation), brightness: &(hsba.brightness), alpha: &(hsba.alpha))
            return hsba
        }

        /// The RGB & alpha attributes of the `UIColor` instance.
        public var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
            var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) = (0, 0, 0, 0)
            getRed(&rgba.red, green: &rgba.green, blue: &rgba.blue, alpha: &rgba.alpha)
            return rgba
        }


        // MARK: - Methods

        /// Creates a new `UIColor` object with a single attribute changed by a given difference using addition.
        ///
        /// - Parameters:
        ///   - attribute: The attribute to change.
        ///   - by: The addition to be added to the current value of the attribute.
        /// - Returns: The resulting new `UIColor` with the specified change applied.
        public func change(_ attribute: ChangeableAttribute, by addition: CGFloat) -> UIColor {

            switch attribute {
            case .red:
                return change(attribute, to: rgba.red + addition)

            case .green:
                return change(attribute, to: rgba.green + addition)

            case .blue:
                return change(attribute, to: rgba.blue + addition)

            case .alpha:
                return change(attribute, to: rgba.alpha + addition)

            case .hue:
                return change(attribute, to: hsba.hue + addition)

            case .saturation:
                return change(attribute, to: hsba.saturation + addition)

            case .brightness:
                return change(attribute, to: hsba.brightness + addition)
            }
        }

        /// Creates a new `UIColor` object with the value of a single attribute set to a given value.
        ///
        /// - Parameters:
        ///   - attribute: The attribute to change.
        ///   - to: The new value to be set for the attribute.
        /// - Returns: The resulting new `UIColor` with the specified change applied.
        public func change(_ attribute: ChangeableAttribute, to newValue: CGFloat) -> UIColor { // swiftlint:disable:this cyclomatic_complexity
            switch attribute {
            case .red, .green, .blue, .alpha:
                var newRgba = self.rgba

                switch attribute {
                case .red:
                    newRgba.red = newValue

                case .green:
                    newRgba.green = newValue

                case .blue:
                    newRgba.blue = newValue

                case .alpha:
                    newRgba.alpha = newValue

                default: break
                }

                return UIColor(red: newRgba.red, green: newRgba.green, blue: newRgba.blue, alpha: newRgba.alpha)

            case .hue, .saturation, .brightness:
                var newHsba = self.hsba

                switch attribute {
                case .hue:
                    newHsba.hue = newValue

                case .saturation:
                    newHsba.saturation = newValue

                case .brightness:
                    newHsba.brightness = newValue

                default: break
                }

                return UIColor(hue: newHsba.hue, saturation: newHsba.saturation, brightness: newHsba.brightness, alpha: newHsba.alpha)
            }
        }
    }
#endif

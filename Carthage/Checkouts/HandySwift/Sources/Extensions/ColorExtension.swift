//
//  ColorExtension.swift
//  HandySwift
//
//  Created by Cihat Gündüz on 17.04.16.
//  Copyright © 2016 Flinesoft. All rights reserved.
//

#if UIKIT
    
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
            case Red, Green, Blue, Hue, Saturation, Brightness, Alpha
        }
        
        // MARK: - Computed Properties
        
        /// The HSB & alpha attributes of the `UIColor` instance.
        public var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
            
            var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) = (0, 0, 0, 0)
            self.getHue(&(hsba.hue), saturation: &(hsba.saturation), brightness: &(hsba.brightness), alpha: &(hsba.alpha))
            return hsba
        }
        
        /// The RGB & alpha attributes of the `UIColor` instance.
        public var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
            
            var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) = (0, 0, 0, 0)
            self.getRed(&rgba.red, green: &rgba.green, blue: &rgba.blue, alpha: &rgba.alpha)
            return rgba
        }
        
        
        // MARK: - Methods
        
        /// Creates a new `UIColor` object with a single attribute changed by a given difference using addition.
        ///
        /// - Parameters:
        ///   - attribute: The attribute to change.
        ///   - by: The addition to be added to the current value of the attribute.
        /// - Returns: The resulting new `UIColor` with the specified change applied.
        public func change(attribute: ChangeableAttribute, by addition: CGFloat) -> UIColor {
            
            switch attribute {
            case .Red:
                return self.change(attribute, to: self.rgba.red + addition)
                
            case .Green:
                return self.change(attribute, to: self.rgba.green + addition)
                
            case .Blue:
                return self.change(attribute, to: self.rgba.blue + addition)
                
            case .Alpha:
                return self.change(attribute, to: self.rgba.alpha + addition)
                
            case .Hue:
                return self.change(attribute, to: self.hsba.hue + addition)
                
            case .Saturation:
                return self.change(attribute, to: self.hsba.saturation + addition)
                
            case .Brightness:
                return self.change(attribute, to: self.hsba.brightness + addition)
            }
            
        }
        
        /// Creates a new `UIColor` object with the value of a single attribute set to a given value.
        ///
        /// - Parameters:
        ///   - attribute: The attribute to change.
        ///   - to: The new value to be set for the attribute.
        /// - Returns: The resulting new `UIColor` with the specified change applied.
        public func change(attribute: ChangeableAttribute, to newValue: CGFloat) -> UIColor {
            
            switch attribute {
            case .Red, .Green, .Blue, .Alpha:
                var newRgba = self.rgba
                
                switch attribute {
                case .Red:
                    newRgba.red = newValue
                    
                case .Green:
                    newRgba.green = newValue
                    
                case .Blue:
                    newRgba.blue = newValue
                    
                case .Alpha:
                    newRgba.alpha = newValue
                    
                default: break
                }
                
                return UIColor(red: newRgba.red, green: newRgba.green, blue: newRgba.blue, alpha: newRgba.alpha)
                
            case .Hue, .Saturation, .Brightness:
                var newHsba = self.hsba
                
                switch attribute {
                case .Hue:
                    newHsba.hue = newValue
                    
                case .Saturation:
                    newHsba.saturation = newValue
                    
                case .Brightness:
                    newHsba.brightness = newValue
                    
                default: break
                }
                
                return UIColor(hue: newHsba.hue, saturation: newHsba.saturation, brightness: newHsba.brightness, alpha: newHsba.alpha)
            }
        }
        
    }
    
    
#endif
//
//  AppColor.swift
//  BouncingColorApps
//
//  Created by Jia Chen Yee on 28/6/24.
//

import Foundation
import AppKit

enum AppColor: CaseIterable {
    case black
    case red
    case yellow
    case green
    case blue
    case purple
    case white
    
    static func from(color: NSColor) -> [Self] {
        let hue = color.hueComponent
        let brightness = color.brightnessComponent
        let saturation = color.saturationComponent
        
        var color: [Self] = []
        
        if saturation > 0.2 && brightness > 0.07 {
            if 0.84...1 ~= hue || 0...0.084 ~= hue {
                color.append(.red)
            }
            
            if 0.072...0.2 ~= hue {
                color.append(.yellow)
            }
            
            if 0.18...0.5 ~= hue {
                color.append(.green)
            }
            
            if 0.48...0.73 ~= hue {
                color.append(.blue)
            }
            
            if 0.7...0.95 ~= hue {
                color.append(.purple)
            }
        }
        
        if brightness < 0.2 || (saturation < 0.5 && brightness < 0.5) {
            color.append(.black)
        }
        
        if brightness >= 0.5 && saturation < 0.5 {
            color.append(.white)
        }
        
        return color
    }
}

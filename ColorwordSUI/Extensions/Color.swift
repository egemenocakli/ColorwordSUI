//
//  Color.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 5.11.2024.
//

import Foundation
import SwiftUICore
import UIKit

extension Color {
    
    static var backgroundColorGradient1: Color {
        return Color("backgroundColor")
    }
    
    static var backgroundColorGradient2: Color {
        return Color("backgroundColor2")
    }
    
    static var appNameColor: Color {
        return Color("appName")
    }
    static var textColorWhite: Color {
        return Color("textColorW")
    }

    // UIColor'ı Color'a çeviren uzantı. hex->rgb
    init?(hex: String) {
        guard let hexNumber = Int(hex.replacingOccurrences(of: "#", with: ""), radix: 16) else { return nil }
        let r = Double((hexNumber >> 16) & 0xFF) / 255.0
        let g = Double((hexNumber >> 8) & 0xFF) / 255.0
        let b = Double(hexNumber & 0xFF) / 255.0
        self = Color(red: r, green: g, blue: b)
    }
    // rgb->hex
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        let hexString = String(
            format: "#%02X%02X%02X",
            Int(red * 255.0),
            Int(green * 255.0),
            Int(blue * 255.0)
        )
        return hexString
    }
    
        static var random: Color {
            let min: UInt32 = 0
            let max: UInt32 = 200

            func randomComponent() -> Double {
                Double(min + arc4random_uniform(max - min)) / 255.0
            }

            return Color(
                red: randomComponent(),
                green: randomComponent(),
                blue: randomComponent()
            )
        }
    
}

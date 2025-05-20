//
//  UIColor+Ext.swift
//  WaterEject
//
//  Created by Talha on 20.05.2025.
//

import UIKit

extension UIColor {
    static let primary = UIColor(hex: "217BFF")
    static let background = UIColor(hex: "0B1723")
    static let titleColor = UIColor(hex: "FFFFFF")
    static let textColor = UIColor(hex: "A5B5C5")
    static let cardBackground = UIColor(hex: "102435")
    static let cardBorder = UIColor(hex: "1E3A53")
    static let disabledCTA = UIColor(hex: "3A4B61")
    static let activeCTA = UIColor(hex: "3198FF")
    static let tabbarUnselected = UIColor(hex: "4C627A")
    static let tabbarBackground = UIColor(hex: "0B1723")
    static let premium = UIColor(hex: "4361EE")
    static let hgcb = UIColor(hex: "1A3E60")
    static let hgbc = UIColor(hex: "2E5C87")
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

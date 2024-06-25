//
//  CustomFonts.swift
//  SavingsApp
//
//  Created by Hiram Castro on 24/06/24.
//

import Foundation
import SwiftUI

public struct CustomFonts {
    static let HelveticaBlkIt: String = "HelveticaBlkIt"
    static let HelveticaNeueBold: String = "HelveticaNeueBold"
    static let HelveticaNeueBoldItalic: String = "HelveticaNeueBoldItalic"
    static let HelveticaNeueCondensedBlack: String = "HelveticaNeueCondensedBlack"
    static let HelveticaNeueCondensedBold: String = "HelveticaNeueCondensedBold"
    static let HelveticaNeueItalic: String = "HelveticaNeueItalic"
    static let HelveticaNeueLight: String = "HelveticaNeueLight"
    static let HelveticaNeueLightItalic: String = "HelveticaNeueLightItalic"
    static let HelveticaNeueMedium: String = "HelveticaNeueMedium"
    static let HelveticaNeueUltraLight: String = "HelveticaNeueUltraLight"
    static let HelveticaNeueUltraLightItal: String = "HelveticaNeueUltraLightItal"
}

extension Font {
    public static let HelveticaBlkIt: Font = .custom(CustomFonts.HelveticaBlkIt, size: 12)
    public static let HelveticaNeueBold: Font = .custom(CustomFonts.HelveticaNeueBold, size: 12)
    public static let HelveticaNeueBoldItalic: Font = .custom(CustomFonts.HelveticaNeueBoldItalic, size: 12)
    public static let HelveticaNeueCondensedBlack: Font = .custom(CustomFonts.HelveticaNeueCondensedBlack, size: 12)
    public static let HelveticaNeueCondensedBold: Font = .custom(CustomFonts.HelveticaNeueCondensedBold, size: 12)
    public static let HelveticaNeueItalic: Font = .custom(CustomFonts.HelveticaNeueItalic, size: 12)
    public static let HelveticaNeueLight: Font = .custom(CustomFonts.HelveticaNeueLight, size: 12)
    public static let HelveticaNeueLightItalic: Font = .custom(CustomFonts.HelveticaNeueLightItalic, size: 12)
    public static let HelveticaNeueMedium: Font = .custom(CustomFonts.HelveticaNeueMedium, size: 12)
    public static let HelveticaNeueUltraLight: Font = .custom(CustomFonts.HelveticaNeueUltraLight, size: 12)
    public static let HelveticaNeueUltraLightItal: Font = .custom(CustomFonts.HelveticaNeueUltraLightItal, size: 12)
}

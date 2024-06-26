//
//  CustomFonts.swift
//  SavingsApp
//
//  Created by Hiram Castro on 24/06/24.
//

import Foundation
import SwiftUI

public enum CustomFonts: String {
    case HelveticaBlkIt = "HelveticaBlkIt"
    case HelveticaNeueBold = "HelveticaNeueBold"
    case HelveticaNeueBoldItalic = "HelveticaNeueBoldItalic"
    case HelveticaNeueCondensedBlack = "HelveticaNeueCondensedBlack"
    case HelveticaNeueCondensedBold = "HelveticaNeueCondensedBold"
    case HelveticaNeueItalic = "HelveticaNeueItalic"
    case HelveticaNeueLight = "HelveticaNeueLight"
    case HelveticaNeueLightItalic = "HelveticaNeueLightItalic"
    case HelveticaNeueMedium = "HelveticaNeueMedium"
    case HelveticaNeueUltraLight = "HelveticaNeueUltraLight"
    case HelveticaNeueUltraLightItal = "HelveticaNeueUltraLightItal"
}


extension Font {
    static func getCustomFont(ofFont font:CustomFonts , ofSize size:CGFloat) -> Font {
        return .custom(font.rawValue, size: size)
    }
}

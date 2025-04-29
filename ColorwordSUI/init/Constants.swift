//
//  Constants.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 17.10.2024.
//

import Foundation
import SwiftUI

class Constants {
    

    static let appName = "ColorWord"
    
    enum AppTheme: String {
        case dark_mode = "DARK_MODE"
        case light_mode = "LIGHT_MODE"
    }
    
    class ColorConstants {
//        static let loginDarkThemeBackgroundGradient = LinearGradient(
//            gradient: Gradient(colors: [
//                //Color(red: 0.0, green: 0.1, blue: 0.2),
//                //Color.black
//                Color.backgroundColorGradient1,
//                Color.backgroundColorGradient2
//                
//            ]),
//            startPoint: .bottom,
//            endPoint: .top
//        )
        
        
//        static let loginLightThemeBackgroundGradient = LinearGradient(
//            gradient: Gradient(colors: [
//                Color(red: 46/255.0, green: 47/255.0, blue: 66/255.0),
//                Color(red: 98/255.0, green: 111/255.0, blue: 134/255.0)
//            ]),
//            startPoint: .bottom,
//            endPoint: .top
//        )
        
        static let loginLightThemeBackgroundGradient = LinearGradient(
            gradient: Gradient(colors: [
                //Color(red: 150/255.0, green: 170/255.0, blue: 192/255.0),
                //Color(red: 55/255.0, green: 79/255.0, blue: 115/255.0)
                Color.backgroundColorGradient1,
                Color.backgroundColorGradient2,
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        
        //Main
        static let blackColor: Color = Color.black
        static let blackTextColor: Color = Color.black
        static let whiteColor: Color = Color.white
        static let whiteTextColor: Color = Color.white
        static let gray: Color = Color.gray
        static let placeHolderTextColor: Color = Color.white.opacity(0.40)
        static let borderColor: Color = Color.white.opacity(0.50)
        static let blackHex: String = "#000000"

        
        static let loginButtonColor: Color = Color(hex: "376193")!
        static let signUpButtonColor: Color = Color(hex: "535F70")!
        

        static let correctButtonColor: Color = Color(hex: "008b00")!
        static let wrongButtonColor: Color = Color(hex: "C62828")!
        
        static let toastMessageBackgroundColor: Color = Color.black.opacity(0.7)
        static let optionButtonBackgroundColor: Color = Color.mChoiceButtonBackground
        static let grayButtonColor: Color = Color.white.opacity(0.6)
        static let homeCardBackgroundColor: Color = Color.white.opacity(0.05)
        static let buttonForegroundColor: Color = Color.white
        
    }
    /// **xSmallSize: 10, smallSize: 20, mSize: 30, lSize: 40, xLSize: 50**
    class FrameSizeConstants {
        static let xSmallSize: CGFloat = 10
        static let smallSize: CGFloat = 20
        static let mSize: CGFloat = 30
        static let lSize: CGFloat = 40
        static let xLSize: CGFloat = 50
    }
    /// **xSmallSize: 10, smallSize: 20, mSize: 30, lmSize: 40, lSize: 50, xlSize: 100, xxlSize: 150, xxxlSize: 200**
    class PaddingSizeConstants {
        static let xSmallSize: CGFloat = 10
        static let smallSize: CGFloat = 20
        static let mSize: CGFloat = 30
        static let lmSize: CGFloat = 40
        static let lSize: CGFloat = 50
        static let xlSize: CGFloat = 100
        static let xxlSize: CGFloat = 150
        static let xxxlSize: CGFloat = 200
        static let fabButtonTrailing: CGFloat = 20
        static let fabButtonBottom: CGFloat = 5
    }
    
    /// **xxSmall: 8, xSmall: 10, small: 12, medium: 15, large: 20, xLarge: 30**
    class SizeRadiusConstants {
        static let buttonShadowRadius: CGFloat = 4
        static let xxSmall: CGFloat = 8
        static let xSmall: CGFloat = 10
        static let small: CGFloat = 12
        static let medium: CGFloat = 15
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 30
    }
    /// **buttonWidth: 150, buttonHeight: 50**
    class ButtonSizeConstants {
        static let buttonWidth: CGFloat = 150
        static let buttonHeight: CGFloat = 50
    }
    /// **xSmall: 12, small: 14, medium: 16, large: 18, xLarge: 20, x2Large: 22, x3Large: 30, x4Large: 40, hugeSize: 60**
    class FontSizeConstants {
        static let xSmall: CGFloat = 12
        static let small: CGFloat = 14
        static let medium: CGFloat = 16
        static let large: CGFloat = 18
        static let xLarge: CGFloat = 20
        static let x2Large: CGFloat = 22
        static let x3Large: CGFloat = 30
        static let x4Large: CGFloat = 40
        static let hugeSize: CGFloat = 60
    }
    /// **leftButton: "chevron.left", rightButton: "chevron.right", correctButton: "checkmark.circle", wrongButton: "xmark.circle"**
    class IconTextConstants {
        static let leftButton = "chevron.left"
        static let rightButton = "chevron.right"
        static let correctButton = "checkmark.circle"
        static let wrongButton = "xmark.circle"
        static let settingsButton = "gearshape.fill"
        static let logOutButton = "rectangle.portrait.and.arrow.right"
        static let okButtonRectangle = "checkmark.rectangle.fill"
        static let addButtonRectangle = "plus"
        static let deleteButtonRectangle = "trash"
    }
    /// **tooShortTimer: 0.2, standardSpringAnimation: 0.5, shortTimer: 0.7, normalTimer: 1**
    class TimerTypeConstants {
        static let tooShortTimer: TimeInterval = 0.2
        static let standardSpringAnimation: TimeInterval = 0.5
        static let shortTimer: TimeInterval = 0.7
        static let normalTimer: TimeInterval = 1
    }
    
    class ScoreConstants {
        static let dailyLoginScoreBonus: Int = 10
        static let dailyTargetScore: Int = 100
        static let multipleChoiceQuestionScore: Int = 5
        
    }
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

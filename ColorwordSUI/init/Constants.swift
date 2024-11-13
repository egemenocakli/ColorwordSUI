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
        static let blackFont: Color = Color.black
        static let whiteFont: Color = Color.white
        static let gray: Color = Color.gray
        static let placeHolderTextColor: Color = Color.white.opacity(0.40)
        static let borderColor: Color = Color.white.opacity(0.30)

        
        static let loginButtonColor: Color = Color(red: 55/255, green: 97/255, blue: 147/255)
        static let signUpButtonColor: Color = Color(red: 83/255.0, green: 95/255.0, blue: 112/255.0)
    }
    
    class SizeConstants {
        static let iconxSmallSize: CGFloat = 18
        static let iconSmallSize: CGFloat = 24
        static let iconMSize: CGFloat = 26
        static let iconLSize: CGFloat = 28
        static let appNameFontSize: CGFloat = 60
    }
    
    class PaddingSizeConstants {
        static let xSmallSize: CGFloat = 10
        static let smallSize: CGFloat = 20
        static let mSize: CGFloat = 30
        static let lmSize: CGFloat = 40
        static let lSize: CGFloat = 50
        static let xlSize: CGFloat = 100
        static let xxlSize: CGFloat = 150
        static let xxxlSize: CGFloat = 200
    }
    
    class SizeRadiusConstants {
        
        static let xxSmall: CGFloat = 8
        static let xSmall: CGFloat = 10
        static let small: CGFloat = 12
        static let medium: CGFloat = 15
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 30
    }
    
    class ButtonSizeConstants {
        static let buttonWidth: CGFloat = 150
        static let buttonHeight: CGFloat = 50
    }
    
    class FontSizeConstants {
        static let xSmall: CGFloat = 12
        static let small: CGFloat = 14
        static let medium: CGFloat = 16
        static let large: CGFloat = 18
        static let xLarge: CGFloat = 20
        static let x2Large: CGFloat = 22
        static let x3Large: CGFloat = 30
        static let x4Large: CGFloat = 40
    }
    
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

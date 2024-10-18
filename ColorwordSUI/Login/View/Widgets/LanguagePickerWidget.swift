//
//  LanguagePickerWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.10.2024.
//

import Foundation
import SwiftUI

struct LanguagePickerWidget: View {
    
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        Button(action: {
            languageManager.currentLanguage = languageManager.currentLanguage == "en" ? "tr" : "en"
        }) {
            Text(languageManager.currentLanguage == "en" ? "TR" : "EN")
                .padding()
                .background(Color.gray.opacity(0.3))
                .foregroundColor(Constants.ColorConstants.whiteFont)
                .cornerRadius(Constants.SizeRadiusConstants.xxSmall)
        }
    }
}

//
//  TranslateButton.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 30.06.2025.
//

import SwiftUI

struct TranslateButton: View {
    
    @ObservedObject var addNewWordVM: AddNewWordViewModel
    @EnvironmentObject var languageManager: LanguageManager

    
    var body: some View {
        Button(action: {
            Task{
                await addNewWordVM.translate(text: addNewWordVM.enteredWord, from: addNewWordVM.mainLanguage ?? supportedLanguages[46], to: addNewWordVM.targetLanguage ?? supportedLanguages[117])
            }
            
        }) {
            Text("translate")
            
        }
        .foregroundStyle(Constants.ColorConstants.whiteColor)
        .frame(width: Constants.ButtonSizeConstants.buttonWidth, height: Constants.ButtonSizeConstants.buttonHeight)
        .background(.translateButton)
        .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
        .environment(\.locale, .init(identifier: languageManager.currentLanguage))
        
    }
    
}

//#Preview {
//    TranslateButton()
//}

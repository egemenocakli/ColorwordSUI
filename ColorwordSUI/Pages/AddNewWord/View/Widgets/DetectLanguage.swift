//
//  DetectLanguage.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 21.06.2025.
//

import SwiftUI

//Gelen güven değerini de ekleyeceğim.
struct DetectLangText: View {
    @ObservedObject var addNewWordVM: AddNewWordViewModel
    @EnvironmentObject var languageManager: LanguageManager

    
    var body: some View {

        
        if (addNewWordVM.detectedLanguageId != nil && addNewWordVM.mainLanguage?.id == "") {
            
            Text("\(Text("detected_language")): \(addNewWordVM.detectedLanguage ?? "")")
                .font(.system(size: Constants.FontSizeConstants.x2Large))
                .foregroundStyle(Color.textColorWhite)
                .padding()
            Text("\(Text("detected_language_score")): %\(addNewWordVM.detectedLanguageTrustScore ?? 0)")
                .font(.system(size: Constants.FontSizeConstants.x2Large))
                .foregroundStyle(Color.textColorWhite)
                .padding()

        }else {
            EmptyView()
        }
        
        
    }
    

}


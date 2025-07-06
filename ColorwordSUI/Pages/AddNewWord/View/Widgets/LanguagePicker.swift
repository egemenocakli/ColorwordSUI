//
//  LanguagePicker.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 21.06.2025.
//

import SwiftUI

struct LanguagePicker: View {
    @State  var selectedLanguage: Language?
    @State  var targetLanguage: Language?
    @EnvironmentObject var languageManager: LanguageManager
    @ObservedObject var addNewWordVM: AddNewWordViewModel

    
    
    var body: some View {
        
        HStack{
            
            Picker("Selection", selection: $selectedLanguage) {
                ForEach(addNewWordVM.mainLangList, id: \.id) { language in
                    Text(LanguageManager.init().currentLanguage == "tr" ? language.name : language.nameEn)
                        .font(.subheadline)
                        .tag(language)
                        .foregroundStyle(Constants.ColorConstants.whiteTextColor)
                       
                }
            }
            .background(.pickerButton)
            .accentColor(.pickerButtonText)
            .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.medium))
            .shadow(radius: Constants.SizeRadiusConstants.buttonShadowRadius)
            .foregroundStyle(Constants.ColorConstants.whiteTextColor)
            .onChange(of: selectedLanguage) { oldValue, newValue in
                addNewWordVM.mainLanguage = selectedLanguage ?? supportedLanguages[46]
                debugPrint("mainLanguage seçilimi yapıldı.", selectedLanguage?.id as Any)
            }
            .layoutPriority(1)
            
            Spacer()
            
            Button{
                selectedLanguage = addNewWordVM.targetLanguage ?? supportedLanguages[117]
                targetLanguage = addNewWordVM.mainLanguage ?? supportedLanguages[46]
                addNewWordVM.mainLanguage = targetLanguage
                addNewWordVM.targetLanguage = selectedLanguage
            }label: {
                Image(systemName: "arrow.left.arrow.right")
                    .frame(width: Constants.FrameSizeConstants.mSize,height: Constants.FrameSizeConstants.mSize)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .layoutPriority(0)
            
            Spacer()

            
            Picker("Selection2", selection: $targetLanguage) {
                ForEach(addNewWordVM.targetLangList, id: \.id) { language in
                    Text(LanguageManager.init().currentLanguage == "tr" ? language.name : language.nameEn)
                        .font(.subheadline)
                        .tag(language)
                        .foregroundStyle(Constants.ColorConstants.whiteTextColor)

                }
            }
            .background(.pickerButton)
            .accentColor(.pickerButtonText)
            .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.medium))
            .shadow(radius: Constants.SizeRadiusConstants.buttonShadowRadius)
            .foregroundStyle(Constants.ColorConstants.whiteTextColor)
            .onChange(of: targetLanguage) { oldValue, newValue in
                addNewWordVM.targetLanguage = targetLanguage ?? supportedLanguages[117]
                debugPrint("TargetLanguage seçimi yapıldı.", targetLanguage?.id as Any)

            }
            .layoutPriority(1)

        }
        .padding(.horizontal, Constants.PaddingSizeConstants.smallSize)
    }
}

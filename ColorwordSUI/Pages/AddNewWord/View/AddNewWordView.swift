//
//  AddNewWord.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 29.04.2025.
//

import SwiftUI

struct AddNewWordView: View {
//    @EnvironmentObject var themeManager: ThemeManager
//    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var addNewWordVM = AddNewWordViewModel()
    private let maxCharacterLimit = 40
    
    
    //TODO: genel bir button eklenecek commonwidgetsa
    var body: some View {
        NavigationStack{
            ZStack{
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)

                GeometryReader { geometry in
                    
                    VStack{
                        
                        Text("Hedef dil seçiniz").padding(.top, 100)
                        
                        HStack{
                            
                            Button {
                                
                            }
                            label: {
                                Text("TR")
                                    .foregroundColor(Constants.ColorConstants.buttonForegroundColor)
                                    .padding()
                                    .background(Constants.ColorConstants.signUpButtonColor)
                                    .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.medium))
                                    .shadow(radius: Constants.SizeRadiusConstants.buttonShadowRadius)
                            }
                            
                            .padding(.horizontal, 50)
                            .padding(.vertical, 10)
                            
                            Button {
                                
                            } label: {
                                Text("EN")
                                    .foregroundColor(Constants.ColorConstants.buttonForegroundColor)
                                    .padding()
                                    .background(Constants.ColorConstants.signUpButtonColor)
                                    .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.medium))
                                    .shadow(radius: Constants.SizeRadiusConstants.buttonShadowRadius)
                            }
                            .padding(.horizontal, 50)
                            .padding(.vertical, 10)


                            
                        }
//                        TextfieldWidget(text: $addNewWordVM.enteredWord, hintKey: "Kelimeyi giriniz")
                        TextEditor(text: $addNewWordVM.enteredWord)
                            .font(.title)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(Color.white.opacity(0.05).blur(radius: 50))
                            .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
                            .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
                            .padding(.all, Constants.PaddingSizeConstants.xSmallSize)
//                            .foregroundColor(.white.opacity(0.8))
                            .frame(minHeight: 60, maxHeight: 110)
                            .limitTextEditorCharacters($addNewWordVM.enteredWord, limit: 40)

                        
                        Spacer()
                        Text("Çeviriniz:")
                        Spacer()
                        

                    }

//                    .environment(\.locale, .init(identifier: languageManager.currentLanguage))
//                    .preferredColorScheme(themeManager.colorScheme)
                }
            }
        }
    }
}

#Preview {
    AddNewWordView()
}

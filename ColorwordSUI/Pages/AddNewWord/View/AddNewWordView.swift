import Foundation
import SwiftUI
import SwiftUICore

struct AddNewWordView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var addNewWordVM = AddNewWordViewModel()
    


    var body: some View {
        NavigationStack {
            ZStack {
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)

                GeometryReader { geometry in
                    VStack {
                        Button{
                            addNewWordVM.cacheverisil()
                        }label: {
                            Text("cachedeki veriyi sil")
                        }
                        Text("Hedef dil seçiniz")
                            .padding(.top, 100)

                        HStack {
                            Button {
                                // Dili Türkçe yap
                                addNewWordVM.translate(text: addNewWordVM.enteredWord, from: "en", to: "tr")
                            } label: {
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
                                // Dili İngilizce yap
                                addNewWordVM.translate(text: addNewWordVM.enteredWord, from: "tr", to: "en")
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

                        TextEditor(text: $addNewWordVM.enteredWord)
                            .fontWeight(.bold)
                            .font(.system(size: Constants.FontSizeConstants.x2Large))
                            .foregroundStyle(Color.textColorWhite)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(Color.white.opacity(0.05).blur(radius: 50))
                            .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
                            .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
                            .padding(.all, Constants.PaddingSizeConstants.xSmallSize)
                            .frame(minHeight: 60, maxHeight: 110)
                            .limitTextEditorCharacters($addNewWordVM.enteredWord, limit: 40)
                        Button(action: {
                            // Çeviri butonuna tıklandığında işlem yapılır.
                            Task{
                                addNewWordVM.loadAzureKFromKeychain()
                                
                                addNewWordVM.translate(text: addNewWordVM.enteredWord, from: "en", to: "tr")
                            }
                            
//                            Task{
//                                await $addNewWordVM.getAzureK
//                            }
                        }) {
                            Text("Çevir")
                                
                        }
                        .foregroundStyle(Constants.ColorConstants.whiteColor)
                        .frame(width: Constants.ButtonSizeConstants.buttonWidth, height: Constants.ButtonSizeConstants.buttonHeight)
                        .background(Constants.ColorConstants.loginButtonColor)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
                        Spacer()

                        if let errorMessage = addNewWordVM.errorMessage {
                            Text("Hata: \(errorMessage)")
                                .foregroundColor(.red)
                        } else {
                            Text(addNewWordVM.translatedText)
                                .fontWeight(.bold)
                                .font(.system(size: Constants.FontSizeConstants.x4Large))
                                .foregroundStyle(Color.textColorWhite)
                                .padding()
                        }

                        Spacer()
                    }
                    .environment(\.locale, .init(identifier: languageManager.currentLanguage))
                    .preferredColorScheme(themeManager.colorScheme)
                    
                    
                }
            }
        }
    }


}

#Preview {
    AddNewWordView()
}

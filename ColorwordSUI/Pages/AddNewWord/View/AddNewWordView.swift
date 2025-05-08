import Foundation
import SwiftUI
import SwiftUICore

struct AddNewWordView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var addNewWordVM = AddNewWordViewModel()
    
    @State var showPicker = false


//TODO: localization eklenecek
    var body: some View {
        NavigationStack {
            ZStack {
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)

                GeometryReader { geometry in
                    VStack {

                        Text("Hedef dil seçiniz")
                            .fontWeight(.bold)
                            .padding(.top, 50)
                            .foregroundStyle(.white)

                        HStack {
                            Button {
                                // Dili Türkçe yap
                                addNewWordVM.translate(text: addNewWordVM.enteredWord, from: "en", to: "tr")
                            } label: {
                                Text("TR")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Constants.ColorConstants.whiteColor)
                                    .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.medium))
                                    .shadow(radius: Constants.SizeRadiusConstants.buttonShadowRadius)
                            }

                            .padding(.horizontal, 50)
                            .padding(.vertical, 10)

                            //iki dil seçeneğini değiştir.
                            Button{
                                
                            }label: {
                                Image(systemName: "arrow.left.arrow.right")
                                    .frame(width: 60,height: 60)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            Button {
                                // Dili İngilizce yap
                                addNewWordVM.translate(text: addNewWordVM.enteredWord, from: "tr", to: "en")
                            } label: {
                                Text("EN")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Constants.ColorConstants.whiteColor)
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
//                                addNewWordVM.loadAzureKFromKeychain()
                                
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
                    .onAppear(){
                        addNewWordVM.loadAzureKFromKeychain()
                    }
                    .environment(\.locale, .init(identifier: languageManager.currentLanguage))
                    .preferredColorScheme(themeManager.colorScheme)
                    .onTapGesture {
                        showPicker.toggle()
                    }
                    .sheet(isPresented: $showPicker, content: {
                        BottomSheetPicker(showPicker: $showPicker, viewModel: addNewWordVM)
                            .presentationDetents([.fraction(0.1)])
                            .presentationCornerRadius(Constants.SizeRadiusConstants.large)

                    })
                    
                    .frame(height: 80)
                    
                }
            }
        }
    }


}

#Preview {
    AddNewWordView()
}

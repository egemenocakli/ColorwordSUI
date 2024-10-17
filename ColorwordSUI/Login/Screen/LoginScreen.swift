//
//  ContentView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 17.10.2024.
//

import SwiftUI


struct LoginScreen: View {
    
    @State var email: String = ""
    @State var password: String = ""

    @StateObject private var languageManager = LanguageManager()


    var body: some View {
        
        
        GeometryReader { geometry in
            ZStack {
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text(Constants.appName).frame(width: UIScreen.main.bounds.width, height: Constants.PaddingSizeConstants.xlSize, alignment: .center).font(.system(size: Constants.SizeConstants.appNameFontSize))
                        .frame(height: geometry.size.height * 0.3)
                        .foregroundStyle(Constants.ColorConstants.whiteFont)
                    
                    GeometryReader { geometry in
                        VStack {
                            VStack {
                                 ZStack(alignment: .leading) {
                                     if email.isEmpty {
                                         Text("email")
                                             .foregroundColor(Constants.ColorConstants.placeHolderTextColor)
                                             .padding(.leading, Constants.PaddingSizeConstants.lmSize)
                                     }
                                     TextField("", text: $email)
                                         .keyboardType(.emailAddress)
                                         .textInputAutocapitalization(.none)
                                         .padding()
                                         .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
                                         .padding(.all, Constants.PaddingSizeConstants.xSmallSize)
                                         .foregroundColor(.white)
                                         
                                 }
                            }
                            
                            VStack {
                                 ZStack(alignment: .leading) {
                                     if password.isEmpty {
                                         Text("login_password")
                                             .foregroundColor(Constants.ColorConstants.placeHolderTextColor)
                                             .padding(.leading, Constants.PaddingSizeConstants.lmSize)
                                     }
                                     TextField("", text: $password)
                                         .textInputAutocapitalization(.none)
                                         .padding()
                                         .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
                                         .padding(.all, Constants.PaddingSizeConstants.xSmallSize)
                                         .foregroundColor(.white)
                                 }
                            }.padding(.bottom, Constants.PaddingSizeConstants.smallSize)
                         
                            
                            
                            Button(action: loginButton) {
                                Text("login_button")
                                    .foregroundStyle(Constants.ColorConstants.whiteFont)
                                    .frame(width: Constants.ButtonSizeConstants.buttonWidth, height: Constants.ButtonSizeConstants.buttonHeight)
                                    .background(Constants.ColorConstants.loginButtonColor)
                                    .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
                            }
                            .contentShape(Rectangle())
                            
                            Button(action: loginButton) {
                                Text("sign_up_button")
                                    .foregroundStyle(Constants.ColorConstants.whiteFont)
                                    .frame(width: Constants.ButtonSizeConstants.buttonWidth, height: Constants.ButtonSizeConstants.buttonHeight)
                                    .background(Constants.ColorConstants.signUpButtonColor)
                                    .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
                            }
                            .contentShape(Rectangle())
                            .padding(.top, Constants.PaddingSizeConstants.xSmallSize)
                            
                            
                            
                            
                            
                        }
                        .padding(.horizontal, Constants.PaddingSizeConstants.smallSize)
                        .frame(height: geometry.size.height * 0.6)
                    }
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
                            .environment(\.locale, .init(identifier: languageManager.currentLanguage))
                    
                }
                
            
            
        }
        
    }

    func changeLanguage(to language: String) {
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.first?.rootViewController = UIHostingController(rootView: LoginScreen())
        }
        
        languageManager.currentLanguage = language
    }
    
    func loginButton() {
        
    }
}
    
#Preview {
    LoginScreen()
}


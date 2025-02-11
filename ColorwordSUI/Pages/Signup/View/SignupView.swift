//
//  SignupScreen.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.10.2024.
//

import SwiftUICore
struct SignupView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject var signUpViewModel = SignupViewModel()
    
    @State private var showToast: Bool = false

    var body: some View {
        ZStack {
            Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)

            GeometryReader { geometry in
                VStack(spacing: 5) {
                    TextfieldWidget(text: $signUpViewModel.name, keyboardType: .default, hintText: "name")
                    TextfieldWidget(text: $signUpViewModel.lastName, keyboardType: .default, hintText: "lastname")
                    TextfieldWidget(text: $signUpViewModel.email, keyboardType: .emailAddress, hintText: "email", textInputAutoCapitalization: .never)
                    TextfieldWidget(text: $signUpViewModel.password, keyboardType: .default, hintText: "password", textInputAutoCapitalization: .never)

                    //TODO: tekrar şifre almayı ekle 2 tane olsun
                    SignupPageButtonWidget(action: {
                        signUpViewModel.signup()
                    })
                    .padding(.bottom, geometry.size.height * 0.1)
                    .frame(height: geometry.size.height * 0.3)
                }
                .padding(.top, geometry.size.height * 0.05)
                
                .overlay(
                    Group {
                        if let message = signUpViewModel.signupResultMessage, showToast {
                            showResultToastMessage(message: message)
                        }
                    }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, geometry.size.height * 0.05)
                )
                
                .onChange(of: signUpViewModel.signupResultMessage) { _, newValue in
                    if newValue != nil {
                        showToast = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showToast = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showToast = false
                        }
                    }
                }
            }
            .environment(\.locale, .init(identifier: languageManager.currentLanguage))

            
        }
        
    }

    fileprivate func showResultToastMessage(message: String) -> some View {
        ZStack {
            ToastWidget(message: message)
                .transition(.slide)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showToast = false
                    }
                }
        }
    }
    

}

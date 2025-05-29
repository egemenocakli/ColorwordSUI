//
//  SignupScreen.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.10.2024.
//

import SwiftUICore
import SwiftUI
struct SignUpView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject var signUpViewModel = SignupViewModel()
    @State private var showToast: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)
                
                GeometryReader { geometry in
                    VStack(spacing: 5) {
                        TextfieldWidget(text: $signUpViewModel.name, keyboardType: .default, hintKey: "name")
                        TextfieldWidget(text: $signUpViewModel.lastName, keyboardType: .default, hintKey: "lastname")
                        TextfieldWidget(text: $signUpViewModel.email, keyboardType: .emailAddress, hintKey: "email", textInputAutoCapitalization: .never)
                        TextfieldWidget(text: $signUpViewModel.password, keyboardType: .default, hintKey: "password", textInputAutoCapitalization: .never)
                        TextfieldWidget(text: $signUpViewModel.repeatPassword, keyboardType: .default, hintKey: "repeat_password", textInputAutoCapitalization: .never)

                        SignupPageButtonWidget(action: {
                            signUpViewModel.signup { success in
                                if success {
                                    print("✅ Kullanıcı başarıyla kaydedildi!")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                       dismiss()
                                     }
                                } else {
                                    print("❌ Kayıt başarısız! Hata: \(signUpViewModel.signupResultMessage ?? "")")
                                }
                            }
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

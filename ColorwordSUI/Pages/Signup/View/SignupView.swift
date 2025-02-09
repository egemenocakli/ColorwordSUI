//
//  SignupScreen.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.10.2024.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject var signUpViewModel = SignupViewModel()
    
    
    
    var body: some View {
        
        GeometryReader { geometry in
            VStack(spacing: 5) {
                
                //TODO: hint vs. çeviri düzeltilecek. renkler açık temada görünmüyor.
                TextfieldWidget(text: signUpViewModel.name, keyboardType: .default, hintText: "Name")
                TextfieldWidget(text: signUpViewModel.lastName, keyboardType: .default, hintText: "Lastname")
                TextfieldWidget(text: signUpViewModel.email, keyboardType: .emailAddress, hintText: "Email",textInputAutoCapitalization: .never)
                TextfieldWidget(text: signUpViewModel.password, keyboardType: .default, hintText: "Password",textInputAutoCapitalization: .never)
                    
                //TODO: viewmodel ve servis kayıt işlemleri
                SignupPageButtonWidget(action: {
                    
                })
                .padding(.bottom, geometry.size.height * 0.1)
                .frame(height: geometry.size.height * 0.3)
                .environment(\.locale, .init(identifier: languageManager.currentLanguage))
                
            }
            .padding(.top, geometry.size.height * 0.05)

        }

            
    }
}

#Preview {
    SignupView()
}

//
//  ContentView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 17.10.2024.
//

import SwiftUI


struct LoginScreen: View {
    


    @StateObject private var languageManager = LanguageManager()
    @StateObject var loginVM = LoginViewModel()

    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)
                
                VStack {
                    AppNameWidget(geometry: geometry)
                    
                    GeometryReader { geometry in
                        VStack {
                            TextfieldWidgets(email: $loginVM.email, password: $loginVM.password)

                            LoginButtonWidget(action: loginButton)
                            
                            SignUpButtonWidget(action: signupButton)
                         
                        }
                        .padding(.horizontal, Constants.PaddingSizeConstants.smallSize)
                        .frame(height: geometry.size.height * 0.6)
                    }
                    LanguagePickerWidget(languageManager: languageManager)
                            }
                            .environment(\.locale, .init(identifier: languageManager.currentLanguage))
                }
        }
        
    }

    
    func loginButton() {
        
    }
    func signupButton() {
        
    }
}
    
#Preview {
    LoginScreen()
}


//
//  ContentView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 17.10.2024.
//

import SwiftUI
import FirebaseAuth

struct LoginScreen: View {
    
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject var loginVM = LoginViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)
                GeometryReader { geometry in
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
                        LanguagePickerWidget()
                    }
                    .environment(\.locale, .init(identifier: languageManager.currentLanguage))
                }
            }
        }
    }
    
    func loginButton() {
        
        //egocakli@gmail.com 123456
        
        
        loginVM.authLogin(email: loginVM.email, password: loginVM.password)
        
//        loginVM.loginWithEmailPassword(email: "egocakli@gmail.com", password: "123456") { firebaseUsermodel in
//            print(firebaseUsermodel?.name ?? "empty name")
//        }
//        


//        Auth.auth().signIn(withEmail: "egemenocakli97@gmail.com", password: "") { result, error in
//            if  error != nil {
//                print(error?.localizedDescription ?? "")
//            }else {
//                print("giriş başarılı")
//            }
//        }
        
        
//        Auth.auth().createUser(withEmail: "falancaadam3131@gmail.com", password: "123456") { result, error in
//            if  error != nil {
//                print(error?.localizedDescription ?? "")
//            }else {
//                print("kayıt başarılı")
//            }
//        }
    }
    func signupButton() { }
}

    
#Preview {
    LoginScreen()
}


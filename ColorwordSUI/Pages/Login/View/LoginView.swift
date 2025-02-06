//
//  ContentView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 17.10.2024.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) private var systemColorScheme
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject var loginVM = LoginViewModel()
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)
                GeometryReader { geometry in
                    VStack {
                        
                        HStack {
                            ThemeSelectToggleButton(isDarkMode: Binding(
                                get: { themeManager.selectedTheme == Constants.AppTheme.dark_mode.rawValue },
                                set: { _ in themeManager.toggleTheme() }
                            ))
                            
                            Spacer()
                            
                            LanguagePickerWidget()
                        }.preferredColorScheme(themeManager.colorScheme)
                            .padding(10)
                        

                        AppNameWidget(geometry: geometry)
                        
                        GeometryReader { geometry in
                            VStack {
                                TextfieldWidgets(email: $loginVM.email, password: $loginVM.password)
                                
                                LoginButtonWidget(action: loginButton).navigationDestination(isPresented: $loginVM.loginSucces) {
//                                    WordListView().navigationBarBackButtonHidden(true)
                                    
                                    HomeView().navigationBarBackButtonHidden(true)
                                    
                                }
                                
                                SignUpButtonWidget(action: signupButton)
                                
                            }
                            .padding(.horizontal, Constants.PaddingSizeConstants.smallSize)
                            .frame(height: geometry.size.height * 0.6)
                        }
                    }
                    .environment(\.locale, .init(identifier: languageManager.currentLanguage))
                    
                 }
            }.alert(
                loginVM.currentAlert?.title ?? "",
                isPresented: $loginVM.showAlert,
                actions: {
                    Button(loginVM.currentAlert?.primaryButtonTitle ?? "", action: loginVM.currentAlert?.primaryAction ?? {})
                    
                },
                message: {
                    Text(loginVM.currentAlert?.message ?? "")
                }
            )
        }

    }
    
 
    func loginButton() {
        
        //egocakli@gmail.com 123456
        
        let validationResult = loginVM.validateInputs()
        
        if validationResult != false {
            loginVM.loginSucces = loginVM.authLogin(email: loginVM.email, password: loginVM.password)

        }
        
       
            
        
        
        
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
    LoginView()
        .environmentObject(LanguageManager())
}


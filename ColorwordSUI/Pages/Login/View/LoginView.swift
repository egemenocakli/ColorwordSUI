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
    let userPreferences = UserPreferences()
    let keychainEncryption = KeychainEncrpyter()
    @StateObject var homeVM = HomeViewModel()



    var body: some View {
        
        NavigationStack {
            ZStack {
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)
                GeometryReader { geometry in
                    VStack {
                        if (userPreferences.savedEmail != "" && keychainEncryption.loadPassword() != "") {
                            ProgressView("loading")
                                .progressViewStyle(CircularProgressViewStyle(tint: Constants.ColorConstants.whiteColor))
                                .navigationDestination(isPresented: $loginVM.loginSuccess) {
                                    
                                    HomeView().navigationBarBackButtonHidden(true)
                                }
                        }
                        else {
                            
                            HStack {
                                ThemeSelectToggleButton(isDarkMode: Binding(
                                    get: {
                                        themeManager.selectedTheme == Constants.AppTheme.dark_mode.rawValue
                                    },
                                    set: { _ in themeManager.toggleTheme()
                                        loginVM.selectedTheme = themeManager.selectedTheme
                                    }
                                ))
                                
                                Spacer()
                                
                                LanguagePickerWidget()
                            }.preferredColorScheme(themeManager.colorScheme)
                                .padding(10)
                            
                            
                            AppNameWidget(geometry: geometry)
                            
                            GeometryReader { geometry in
                                VStack {
                                    TextfieldWidgets(email: $loginVM.email, password: $loginVM.password)
                                        
                                    
                                    LoginButtonWidget(action: loginVM.authLogin)
                                        .navigationDestination(isPresented: $loginVM.loginSuccess) {
                                            
                                            HomeView().navigationBarBackButtonHidden(true)
                                        }
                                    
                                    
                                    SignUpButtonWidget(action: signupButton)
                                    
                                }
                                .padding(.horizontal, Constants.PaddingSizeConstants.smallSize)
                                .frame(height: geometry.size.height * 0.6)
                            }
                        }
                        
                    }.environment(\.locale, .init(identifier: languageManager.currentLanguage))

                }
            }.onAppear(){
                autoLoginCheck()
            }
            .overlay(
                Group {
                    if let message = loginVM.loginResultMessage, loginVM.showToast {
                        showResultToastMessage(message: message)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 50) // Toast konumlandırma
            )
            }
            


    }
    func signupButton() {
    }
    
    /// **Toast mesajını gösteren metod**
    fileprivate func showResultToastMessage(message: String) -> some View {
        ZStack {
            ToastWidget(message: message)
                .transition(.slide)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        loginVM.showToast = false
                    }
                }
        }
    }
    
    fileprivate func autoLoginCheck () {
        if (userPreferences.savedEmail != "" && keychainEncryption.loadPassword() != "") {
            loginVM.email = userPreferences.savedEmail
            loginVM.password = keychainEncryption.loadPassword()!
            loginVM.authLogin()
            loginVM.loginSuccess = true
            
        }
    }
}

    
#Preview {
    LoginView()
        .environmentObject(LanguageManager())
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

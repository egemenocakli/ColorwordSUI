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

    @State private var goSignUp = false
    @State private var isAutoLoginInProgress = true

    @State private var presenter: UIViewController?   // köprüden gelecek


    var body: some View {
        
        NavigationStack {
            ZStack {
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)
                GeometryReader { geometry in
                    VStack {
                        if (isAutoLoginInProgress) {
                            ProgressView("loading")
                                .progressViewStyle(CircularProgressViewStyle(tint: Constants.ColorConstants.whiteColor))
                                
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
                                .padding(Constants.PaddingSizeConstants.xxSmallSize)
                            
                            
                            AppNameWidget(geometry: geometry)
                                .padding(.vertical, Constants.PaddingSizeConstants.smallSize)
                            
                            GeometryReader { geometry in
                                VStack {
                                    TextfieldWidgets(email: $loginVM.email, password: $loginVM.password)
                                        
                                    
                                    ButtonWidget(titleKey: "login_button",width: Constants.ButtonSizeConstants.buttonWidth, height: Constants.ButtonSizeConstants.buttonHeight, backgroundColor: Constants.ColorConstants.loginButtonColor,fontWeight: .semibold, action: loginVM.authLogin)
                                    

                                        
                                        ButtonWidget(titleKey: "sign_up_button",width: Constants.ButtonSizeConstants.buttonWidth, height: Constants.ButtonSizeConstants.buttonHeight, backgroundColor: Constants.ColorConstants.signUpButtonColor,fontWeight: .semibold, action: signupAction)
                                        .navigationDestination(isPresented: $goSignUp) {
                                            SignUpView().navigationBarBackButtonHidden(false)
                                        }
                                    
                                    
                                    LabeledDivider("OR",labelBackground: Constants.ColorConstants.transparentColor)
                                        .padding(.top, Constants.PaddingSizeConstants.mSize)
                                    
                                    
                                }
                                .padding(.horizontal, Constants.PaddingSizeConstants.smallSize)
                                .frame(height: geometry.size.height * 0.85)
                            }
                        }
                        
                    }

                }
            }
            .background(
                NavigationLink(
                    destination: HomeView().navigationBarBackButtonHidden(true),
                    isActive: $loginVM.loginSuccess
                ) { EmptyView() }
                .hidden()
            )
            .onAppear(){
                isAutoLoginInProgress = true
                Task {
                    let succes = autoLoginCheck()
                    if !succes {
                        isAutoLoginInProgress = false
                    }
                }
            }
            .overlay(
                Group {
                    if let err = loginVM.errorMessage {
                        Text(err).foregroundStyle(.red).font(.footnote)
                    }
                }
                )
            .overlay(
                Group {
                    if let message = loginVM.loginResultMessage, loginVM.showToast {
                        showResultToastMessage(message: message)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, Constants.PaddingSizeConstants.lSize) // Toast konumlandırma
            )
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8){

                    //GoogleLoginButton(action: googleLoginAction)
                    
                    //Viewmodelden çekmeli signInwithGoogle ı
                    GoogleLoginButton {
                        Task { await loginVM.signInWithGoogle(presenter: presenter) }
                    }
                    .disabled(presenter == nil || loginVM.isLoading)
                    .opacity(loginVM.isLoading ? 0.7 : 1)
                    .background(PresenterControllerReader(controller: $presenter))


                }
                .padding(.horizontal, Constants.PaddingSizeConstants.smallSize)
                .padding(.vertical, Constants.PaddingSizeConstants.mSize)
                
            }

            }

        .environment(\.locale, .init(identifier: languageManager.currentLanguage))
        .animation(.easeInOut(duration: 0.25), value: languageManager.currentLanguage)
        .onChange(of: loginVM.loginSuccess) { _, newVal in
            debugPrint("loginSuccess changed:", newVal)
        }



            


    }
    
    func signupAction() {
        goSignUp = true
    }
    func googleLoginAction() {
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
    
    //autoLogin
    @discardableResult
    fileprivate func autoLoginCheck () -> Bool {
        guard
            !userPreferences.savedEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let password = keychainEncryption.loadPassword(),
            !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return false
        }
        loginVM.email = userPreferences.savedEmail
        loginVM.password = password
        loginVM.authLogin()
        
        return true
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

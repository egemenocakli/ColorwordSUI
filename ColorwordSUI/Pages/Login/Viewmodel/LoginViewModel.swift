//
//  LoginViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.10.2024.
//

import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    
    let loginService = LoginService()
    
    //TODO:giriş bilgileri silinip locale kaydedilen veriler ile auto giriş vs.
    @Published var email: String = "bobafettkimlan@gmail.com"
    @Published var password: String = "123456"
    @Published var name: String = ""
    @Published var lastName: String = ""
    @Published var showAlert = false
    @Published var loginSucces = false
    var currentAlert: CommonAlertDialog?
    var firebaseErrorMessage: String? ///TODO: firebaseden gelen mesajları buraya atıp aşağıya gönderebilirim. veya şartların hepsini karşılyorsa firebaseden gelen mesajı yazdırabilriim.
    
    
        
        private let validationManager = ValidationManager() // ValidationManager kullanıyoruz
        
        func validateInputs() -> Bool {
            if let validationError = validationManager.validate(email: email, password: password) {
                switch validationError {
                case .emptyFields:
                    currentAlert = CommonAlertDialog(
                        title: "Error",
                        message: "Email or Password can't be empty.",
                        primaryButtonTitle: "Ok",
                        secondaryButtonTitle: nil,
                        primaryAction: { },
                        secondaryAction: {nil}
                    )
                    
                case .shortPassword:
                    currentAlert = CommonAlertDialog(
                        title: "Error",
                        message: "Password must be at least 6 characters long.",
                        primaryButtonTitle: "Ok",
                        secondaryButtonTitle: nil,
                        primaryAction: {  },
                        secondaryAction: {nil}
                    )
                    
                case .invalidEmail:
                    currentAlert = CommonAlertDialog(
                        title: "Error",
                        message: "Invalid email format.",
                        primaryButtonTitle: "Ok",
                        secondaryButtonTitle: nil,
                        primaryAction: {  },
                        secondaryAction: { nil}
                    )
                }
                
                showAlert = true
                return false
            }else {
                return true
            }
        }
    
    func authLogin (email: String, password: String) -> Bool{
        
            loginService.loginWithEmailPassword(email: email, password: password) { [weak self] success, user in
                if success, let user = user {
                    print("User logged in: \(user.email)")
                    UserSessionManager.shared.updateUser(with: user)
                    self?.loginSucces = true
                } else {
                    print("Login failed")
                    self?.loginSucces = false
                }
            }
        return loginSucces
    }
    
    
    ///TODO: Genel bir textfield form doldurma kontrolü yapılacak eğer şartlar sağlanıyorsa aşağıdaki metod çalışacak.
//    func authLogin(email: String, password: String) -> Bool{
//        
//        
//        if (email != "" && password != "") {
//         
//            loginService.loginWithEmailPassword(email: email, password: password, completion: { usermodel in
//                print(usermodel?.userId ?? "empty name")
//                ///TODO: burada singleton olan user modeline ulaşıp içeriği dolu mu değilmi kontrolü yapabiliriz sonuca göre sonraki sayfaya geçer
//                
//                
//            })
//            loginSucces = true
//            return loginSucces
//        }else {
//            ///TODO: genel dizinde bir widget klasörü oluşturup Alert widget yapılcak
//            loginSucces = false
//            return loginSucces
//        }
//  
//    }
//    
    func authSignUp(email: String, password: String) {
        
        if (email != "" && password != "") {
            loginService.signUp(email: email, password: password,name: name, lastName: lastName, completion: { result in
                
                if result == true {
                    print("SignUp Succes")
                    
                    ///TODO: Alınan bilgiler ya burada tekrar bir metod ile signleton olan user a gönderilecek ya da firebase metodu içerisinde olacak.

                }else {
                    print("Signup Failed")
                    
                    ///TODO: Alert gösterimi - kayıt başarısız
                }
            })
        }else {
            ///TODO: Alert gösterimi - Alanlar uygun şekilde doldurulmadı ya da direkt firebaseden gelen mesaj gösterilecek
        }
    }
    
    func changeLanguage(to language: String, languageManager: LanguageManager) {
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.first?.rootViewController = UIHostingController(rootView: LoginView())
        }
        
        languageManager.currentLanguage = language
    }
//    
//    func login() {
//        loginService?.loginWithEmailPassword(email: "egocakli@gmail.com", password: "123456") { [weak self] user in
//              if let user = user {
//                  // Başarılı login işlemi, kullanıcı bilgilerini burada işleyin
//                  print("Login successful for user: \(user.email)")
//                  // Burada ViewModel içinde duruma göre bir state güncellemesi yapabilirsiniz
//                  self?.handleSuccessfulLogin(user: user)
//              } else {
//                  // Login başarısız oldu, hata mesajını burada işleyin
//                  print("Login failed")
//                  self?.handleLoginFailure()
//              }
//          }
//      }
//    private func handleSuccessfulLogin(user: FirebaseUserModel) {
//         // Kullanıcı bilgilerini kaydedebilir veya ilgili UI güncellemesini yapabilirsiniz
//         // Örneğin:
//         print("Kullanıcı ID: \(user.userId), Email: \(user.email)")
//     }
//    private func handleLoginFailure() {
//         // Giriş başarısız olduğunda yapılacak işlemler
//         // Örneğin, bir hata mesajı gösterebilir veya kullanıcıya uyarı verebilirsiniz
//         print("Giriş işlemi başarısız oldu.")
//     }
}

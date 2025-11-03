//
//  LoginViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.10.2024.
//

import Foundation
import SwiftUI
import GoogleSignIn
import FirebaseAuth

@MainActor
class LoginViewModel: ObservableObject {
        
    //TODO:giriş bilgileri silinip locale kaydedilen veriler ile auto giriş vs.
    let loginService = LoginService()
    
    @Published var email: String = "" //"bobafettkimlan@gmail.com"
    @Published var password: String = "" //"123456"
    @Published var loginResultMessage: String?
    @Published var showToast = false
    @Published var selectedTheme : String?
    
    private let validationManager = ValidationManager()
    let userPreferences = UserPreferences()
    let keychainEncrpyter = KeychainEncrpyter()
    
    //@Published var presenter: UIViewController?   // Google’ın isteyeceği VC

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUserEmail: String?
    @Published var loginSuccess = false  

    
    
        
    /// **Giriş bilgilerinin doğruluğunu kontrol eden metod**
    func validateInputs() -> Bool {
        if let validationError = validationManager.validate(email: email, password: password) {
            DispatchQueue.main.async {
                self.loginResultMessage = self.getLocalizedValidationError(validationError)
                self.showToastMessage()
            }
            return false
        }
        return true
    }

    //TODO: async e çevrilecek
    /// **Firebase Authentication ile giriş yapan metod**
    func authLogin() {
        guard validateInputs() else { return }
        
        loginService.loginWithEmailPassword(email: email, password: password) { [weak self] response in
            DispatchQueue.main.async {
                switch response {
                case .success(let user):
                    print("✅ Kullanıcı giriş yaptı: \(user.email)")
                    UserSessionManager.shared.updateUser(with: user)
                    HomeViewModel.shared.changeLoginSuccesState()
                    self?.loginResultMessage = Bundle.main.localizedString(forKey: "login_success", value: nil, table: nil)
                    self?.loginSuccess = true
                    self?.showToastMessage()
                    self?.saveUserData()
                    
                    
                case .failure(let error):
                    print("❌ Giriş başarısız: \(error.localizedDescription)")
                    self?.loginResultMessage = error.localizedDescription
                    self?.showToastMessage()
                }
            }
        }
    }
    
    //TODO: buradaki öneriler değerlendirilcek
    func signInWithGoogle(presenter: UIViewController?) async {
        guard let presenter else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            try await loginService.signInwithGoogle(presenter: presenter)
            await MainActor.run {
                self.loginSuccess = true
                HomeViewModel.shared.changeLoginSuccesState()

            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }



    /// **Hata mesajlarını döndüren yardımcı metod**
    private func getLocalizedValidationError(_ error: ValidationError) -> String {
        switch error {
        case .emptyFields:
            return Bundle.main.localizedString(forKey: "empty_fields", value: nil, table: nil)
        case .shortPassword:
            return Bundle.main.localizedString(forKey: "short_password", value: nil, table: nil)
        case .invalidEmail:
            return Bundle.main.localizedString(forKey: "email_message", value: nil, table: nil)
        }
    }

    /// **Toast mesajını göstermek için kullanılacak metod**
    private func showToastMessage() {
        self.showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showToast = false
        }
    }

    private func saveUserData () {
        userPreferences.savedEmail = email
        userPreferences.savedTheme = selectedTheme ?? "LIGHT_MODE"
        keychainEncrpyter.savePassword(password)
        
        print(userPreferences.savedEmail)
        print(userPreferences.savedTheme)
        print(userPreferences.savedAzureK)
    }

}

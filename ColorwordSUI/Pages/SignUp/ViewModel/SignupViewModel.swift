//
//  SignupViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.02.2025.
//

import Foundation

class SignupViewModel: ObservableObject {
    let signupService = SignupService()
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var repeatPassword: String = ""
    @Published var name: String = ""
    @Published var lastName: String = ""
    @Published var signupResultMessage: String?
    var validationManager = ValidationManager()
    
    let userPreferences = UserPreferences()
    let keychainEncrpyter = KeychainEncrpyter()

    func signup(completion: @escaping (Bool) -> Void) {
        // **1. ValidationManager ile kontrol et**
        if let validationError = validationManager.validate(email: email, password: password) {
            DispatchQueue.main.async {
                self.signupResultMessage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.signupResultMessage = self.getLocalizedValidationError(validationError)
                }
            }
            completion(false)
            return
        }

        // **2. Alanların boş olup olmadığını kontrol et**
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty, !lastName.isEmpty else {
            DispatchQueue.main.async {
                self.signupResultMessage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.signupResultMessage = Bundle.main.localizedString(forKey: "empty_fields", value: nil, table: nil)
                }
            }
            completion(false)
            return
        }

        // **3. Şifrelerin eşleşip eşleşmediğini kontrol et**
        guard !repeatPassword.isEmpty, password == repeatPassword else {
            DispatchQueue.main.async {
                self.signupResultMessage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.signupResultMessage = Bundle.main.localizedString(forKey: "passwords_not_match", value: nil, table: nil)
                }
            }
            completion(false)
            return
        }

        // **4. Tüm kontroller başarılıysa kayıt işlemini başlat**
        signupService.signUp(email: email, password: password, name: name, lastName: lastName) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let userId):
                    print("✅ Kullanıcı başarıyla kaydedildi. Kullanıcı ID: \(userId)")
                    self.signupResultMessage = Bundle.main.localizedString(forKey: "registration_success", value: nil, table: nil)
                    Task{
                        do{
                            try await self.getAzureK()
                        }catch{
                            throw error
                        }
                    }
                    completion(true)

                case .failure(let error):
                    print("❌ Hata oluştu: \(error.localizedDescription)")
                    self.signupResultMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    /// **Validation hatalarına göre localized mesaj döndüren yardımcı fonksiyon**
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
    func getAzureK() async throws -> String? {
        let azureK: String?
        do{
            azureK = try await signupService.getAzureK() ?? ""
//            userPreferences.savedAzureK = azureK ?? ""
            keychainEncrpyter.saveAzureK(azureK ?? "")
            
            print(userPreferences.savedAzureK)
        }catch{
            throw error
        }
        return azureK
    }
}

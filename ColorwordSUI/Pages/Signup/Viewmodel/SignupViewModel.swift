//
//  SignupViewmodel.swift
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
    
    
    // Boş alanları kontrol et
    //TODO: guard mantığını incele not al yoksa
    //TODO: çeviriler yapılcak
    //firebase geri dönüş mesajları gösterilebilir veya kontrol altına alınıp uygun şekilde mesaj olarak verilir
    func signup(completion: @escaping (Bool) -> Void) {
        // **1. ValidationManager ile kontrol et**
        if let validationError = validationManager.validate(email: email, password: password) {
            DispatchQueue.main.async {
                self.signupResultMessage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    switch validationError {
                    case .emptyFields:
                        self.signupResultMessage = "Lütfen alanları boş bırakmayın."
                    case .shortPassword:
                        self.signupResultMessage = "Şifreniz en az 6 karakterden oluşmalıdır."
                    case .invalidEmail:
                        self.signupResultMessage = "Geçerli bir e-posta adresi giriniz."
                    }
                }
            }
            completion(false) // ❌ Başarısız
            return
        }

        // **2. Alanların boş olup olmadığını kontrol et**
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty, !lastName.isEmpty else {
            DispatchQueue.main.async {
                self.signupResultMessage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.signupResultMessage = "Alanlar boş bırakılamaz!"
                }
            }
            completion(false) // ❌ Başarısız
            return
        }

        // **3. Şifrelerin eşleşip eşleşmediğini kontrol et**
        guard !repeatPassword.isEmpty, password == repeatPassword else {
            DispatchQueue.main.async {
                self.signupResultMessage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.signupResultMessage = "Şifreler uyuşmuyor!"
                }
            }
            completion(false) // ❌ Başarısız
            return
        }

        // **4. Tüm kontroller başarılıysa kayıt işlemini başlat**
        signupService.signUp(email: email, password: password, name: name, lastName: lastName) { result, userId in
            DispatchQueue.main.async {
                if result, let userId = userId, !userId.isEmpty {
                    self.createUserInfo(userId: userId) { createResult in
                        DispatchQueue.main.async {
                            if createResult {
                                self.signupResultMessage = "Kayıt Başarılı"
                                completion(true) // ✅ Başarılı
                            } else {
                                self.signupResultMessage = "Kullanıcı bilgileri kaydedilirken hata oluştu!"
                                completion(false) // ❌ Kullanıcı bilgileri kaydedilemedi
                            }
                        }
                    }
                } else {
                    self.signupResultMessage = "Kayıt başarısız, lütfen tekrar deneyin."
                    completion(false) // ❌ Kayıt başarısız
                }
            }
        }
    }

    
    func createUserInfo(userId: String, completion: @escaping (Bool) -> Void) {
        signupService.createUserInfo(email: email, name: name, lastName: lastName, userId: userId) { success in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}

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
    @Published var name: String = ""
    @Published var lastName: String = ""
    @Published var signupResultMessage: String?

    func signup() {
        // Boş alanları kontrol et
        //TODO: guard mantığını incele not al yoksa
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty, !lastName.isEmpty else {
            DispatchQueue.main.async {
                self.signupResultMessage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.signupResultMessage = "Alanlar boş bırakılamaz!"
                }
            }
            return
        }

        signupService.signUp(email: email, password: password, name: name, lastName: lastName) { result, resultMessage in
            DispatchQueue.main.async {
                self.signupResultMessage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.signupResultMessage = result ? "Kayıt Başarılı" : (resultMessage ?? "Kayıt Başarısız")
                }
            }
        }
    }



}

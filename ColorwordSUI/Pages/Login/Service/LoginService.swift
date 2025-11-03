//
//  LoginService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 21.10.2024.
//

import Foundation
import UIKit


protocol LoginServiceInterface {
    
    
    func loginWithEmailPassword(email: String, password: String, completion: @escaping (ServiceResponse<FirebaseUserModel>) -> Void)
    
    
}

class LoginService: LoginServiceInterface {
    
    private let firebaseAuthService = FirebaseAuthService()

    func loginWithEmailPassword(email: String, password: String, completion: @escaping (ServiceResponse<FirebaseUserModel>) -> Void) {
        firebaseAuthService.loginWithEmailPassword(email: email, password: password) { response in
            switch response {
            case .success(let user):
                print("✅ Kullanıcı giriş yaptı: \(user.email)")
                completion(.success(user))
                
            case .failure(let error):
                print("❌ Giriş hatası: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    //TODO: errorlar metod içinde gönderilecek.

    func signInwithGoogle(presenter: UIViewController?) async {
        guard let presenter else { return }
        do {
            try await firebaseAuthService.signInWithGoogle(presenter: presenter)
        } catch {
            debugPrint(error)
        }    }
}




//     func loginWithEmailPassword(email: String, password: String, completion: @escaping (FirebaseUserModel?) -> Void) {
//        firebaseAuthService.loginWithEmailPassword(email: email, password: password, completion: { user in
//            if let user = user {
//                // Başarılı login işlemi
//                print("Login successful: \(user.email)")
//            } else {
//                // Login hatası
//                print("Login failed")
//            }
//        })
//        }

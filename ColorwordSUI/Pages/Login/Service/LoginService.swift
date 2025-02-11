//
//  LoginService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 21.10.2024.
//

import Foundation


protocol LoginServiceInterface {
    
    
    func loginWithEmailPassword(email: String, password: String, completion: @escaping (Bool, FirebaseUserModel?) -> Void)
    
}

class LoginService: FirebaseAuthService, LoginServiceInterface {
    
    let firebaseAuthService = FirebaseAuthService()

    override func loginWithEmailPassword(email: String, password: String, completion: @escaping (Bool, FirebaseUserModel?) -> Void) {
        firebaseAuthService.loginWithEmailPassword(email: email, password: password) { success,user in
            if let user = user {
                // Başarılı login işlemi
                print("Login successful: \(user.email)")
                completion(true, user)
            } else {
                // Login hatası
                print("Login failed")
                completion(false, nil)
            }
        }
    }
    
    
    

    
    
    
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

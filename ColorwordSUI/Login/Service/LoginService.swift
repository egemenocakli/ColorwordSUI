//
//  LoginService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 21.10.2024.
//

import Foundation


protocol LoginServiceInterface {
    
    
    func loginWithEmailPassword(email: String, password: String, completion: @escaping (FirebaseUserModel?) -> Void)
    func signUp(email: String, password: String, name: String, lastName: String, completion: @escaping (Bool) -> Void)
    
}

class LoginService: FirebaseAuthService, LoginServiceInterface {
    
    let firebaseAuthService = FirebaseAuthService()

    
    
    override func loginWithEmailPassword(email: String, password: String, completion: @escaping (FirebaseUserModel?) -> Void) {
        firebaseAuthService.loginWithEmailPassword(email: email, password: password, completion: { user in
            if let user = user {
                // Başarılı login işlemi
                print("Login successful: \(user.email)")
            } else {
                // Login hatası
                print("Login failed")
            }
        })
        }
    
    
    
    override func signUp(email: String, password: String, name: String, lastName: String, completion: @escaping (Bool) -> Void) {
        
    }
    
    
    
    
}

//
//  SignupService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 10.02.2025.
//

protocol SignupInterface {
    func signUp(email: String, password: String, name: String, lastName: String, completion: @escaping (Bool, String?) -> Void)
}

class SignupService: FirebaseAuthService, SignupInterface {
    private let firebaseAuthService = FirebaseAuthService()
    
    func signUp(email: String, password: String, name: String, lastName: String, completion: @escaping (Bool, String?) -> Void) {
        
        firebaseAuthService.signUp(email: email, password: password, name: name, lastName: lastName) { result in
            
            if result {
                completion(true, nil)
            } else {
                completion(false, "Something went wrong")
            }
        }
    }
    
    
    

    

    
}

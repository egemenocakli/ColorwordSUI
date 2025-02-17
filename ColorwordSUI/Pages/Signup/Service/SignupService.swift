//
//  SignupService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 10.02.2025.
//

protocol SignupInterface {
    func signUp(email: String, password: String, name: String, lastName: String, completion: @escaping (Bool, String?) -> Void)
    func createUserInfo(email: String, name: String, lastName: String, userId: String, completion: @escaping (Bool) -> Void)
}

class SignupService: FirebaseAuthService, SignupInterface {

    

    private let firebaseAuthService = FirebaseAuthService()
    private let firestoreService = FirestoreService()
    
    func signUp(email: String, password: String, name: String, lastName: String, completion: @escaping (Bool, String?) -> Void) {
        
        firebaseAuthService.signUpDb(email: email, password: password, name: name, lastName: lastName) { result,uid  in
            
            if result {
                completion(true, uid)
            } else {
                completion(false, "Something went wrong")
            }
        }
    }
    
    func createUserInfo(email: String, name: String, lastName: String, userId: String, completion: @escaping (Bool) -> Void)  {
        
        firestoreService.createUserInfo(email: email, name: name, lastName: lastName, userUid: userId) { result in
            if result {
                completion(true)
            }else {
                completion(false)
            }
        }

        
        
    }


    

    
}

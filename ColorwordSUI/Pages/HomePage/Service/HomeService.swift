//
//  HomeService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 6.02.2025.
//

protocol HomeServiceInterface {
    func signOut(completion: @escaping (Bool) -> Void)
}

class HomeService {
    private let firebaseAuthService = FirebaseAuthService()

    
    func signOut(completion: @escaping (Bool) -> Void) {
        firebaseAuthService.signOut { result in
    
    
            completion(result)
        }
    
    }
    
}

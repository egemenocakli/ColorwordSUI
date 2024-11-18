//
//  HomeService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.11.2024.
//

import Foundation

protocol HomeServiceInterface {
    func getWordList() async throws -> [Word]
    func signOut(completion: @escaping (Bool) -> Void)
}

class HomeService: HomeServiceInterface {
    private let firebaseAuthService = FirebaseAuthService()
    private let firestoreService = FirestoreService()
    var words : [Word] = []
    
    func getWordList() async throws -> [Word] {
        do {
            words = try await firestoreService.getWordList()
            
        } catch {
            print(error)
        }
        return words
    }
    
    func signOut(completion: @escaping (Bool) -> Void) {
        firebaseAuthService.signOut { result in
            
             
            completion(result)
        }

    }
    
}

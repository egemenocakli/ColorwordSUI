//
//  HomeService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.11.2024.
//

import Foundation

protocol HomePageServiceInterface {
    func getWordList() async throws -> [Word]
}

class HomePageService: HomePageServiceInterface {
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
    
    
    
}

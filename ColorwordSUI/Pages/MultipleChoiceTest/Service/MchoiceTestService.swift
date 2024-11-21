//
//  MchoiceTestService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 22.11.2024.
//

import Foundation

protocol MchoiceTestServiceInterface {
    func getWordList() async throws -> [Word]
}

class MchoiceTestService: MchoiceTestServiceInterface {
    private let firestoreService = FirestoreService()
    var words : [Word] = []
    
    func getWordList() async throws -> [Word] {
        
        do {
            words = try await firestoreService.getWordList()
        }catch {
            print(error)
        }
        return words
    }
    
    
}

//
//  MchoiceTestService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 22.11.2024.
//

import Foundation

protocol MchoiceTestServiceInterface {
    func getWordList() async throws -> [Word]
    func increaseWordScore(word: Word, points: Int) async throws
    func decreaseWordScore(word: Word, points: Int) async throws
    func increaseUserInfoPoints(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void)

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
    
    func increaseWordScore(word: Word, points: Int) async throws {
        do {
            try await firestoreService.increaseWordScore(word: word, points: points)
        }catch{
            print(error)
        }
    }
    func decreaseWordScore(word: Word, points: Int) async throws {
        do {
            try await firestoreService.decreaseWordScore(word: word, points: points)
        }catch{
            print(error)
        }
    }
    
    func increaseUserInfoPoints(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void) {
        
        firestoreService.increaseDailyPoints(for: userInfo) { result in
            completion(result)
        }
    }
}

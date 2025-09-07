//
//  MchoiceTestService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 22.11.2024.
//

import Foundation

protocol MchoiceTestServiceInterface {
    func getWordList(selectedWordList: String) async throws -> [Word]
    func increaseWordScore(selectedWordList: String,word: Word, points: Int) async throws
    func decreaseWordScore(selectedWordList: String,word: Word, points: Int) async throws
    func increaseUserInfoPoints(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void)
    func updateLeaderboardScore(by score: Int, userInfo: UserInfoModel?) async throws

}

class MchoiceTestService: MchoiceTestServiceInterface {

    
    private let firestoreService = FirestoreService()
    var words : [Word] = []
    
    func getWordList(selectedWordList: String) async throws -> [Word] {
        //TODO: düzenlenecek
        do {
            words = try await firestoreService.getWordList(wordListname: selectedWordList)
        }catch {
            debugPrint(error)
        }
        return words
    }
    
    func increaseWordScore(selectedWordList: String,word: Word, points: Int) async throws {
        do {
            try await firestoreService.increaseWordScore(selectedWordList: selectedWordList, word: word, points: points)
        }catch{
            debugPrint(error)
        }
    }
    func decreaseWordScore(selectedWordList: String,word: Word, points: Int) async throws {
        do {
            debugPrint("selectedWordList")
            debugPrint(selectedWordList)
            try await firestoreService.decreaseWordScore(selectedWordList: selectedWordList, word: word, points: points)
        }catch{
            debugPrint(error)
        }
    }
    
    func increaseUserInfoPoints(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void) {
        
        firestoreService.increaseDailyPoints(for: userInfo) { result in
            completion(result)
        }
    }
    
    func updateLeaderboardScore(by score: Int, userInfo: UserInfoModel?) async throws {
        do{
            try await firestoreService.updateLeaderboardScore(by: score, userInfo: userInfo)
            
        }catch{
            debugPrint(error)
        }
    }
}

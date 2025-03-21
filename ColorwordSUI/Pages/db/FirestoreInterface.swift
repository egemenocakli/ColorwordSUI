//
//  FirestoreInterface.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 12.11.2024.
//

import Foundation

protocol FirestoreInterface {
    func getWordList() async throws -> [Word]
    func increaseWordScore(word: Word, points: Int) async throws
    func decreaseWordScore(word: Word, points: Int) async throws
    func createOrUpdateUserInfo(user: UserInfoModel, completion: @escaping (Bool) -> Void)
    func fetchUserInfo (userId: String, completion: @escaping (UserInfoModel?) -> Void)
    func increaseDailyPoints(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void)
    func resetDailyScore(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void)

}

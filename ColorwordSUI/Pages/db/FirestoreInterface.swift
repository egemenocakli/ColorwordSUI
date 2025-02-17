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
    func createUserInfo(email: String, name: String, lastName: String, userUid: String, completion: @escaping (Bool) -> Void)

}

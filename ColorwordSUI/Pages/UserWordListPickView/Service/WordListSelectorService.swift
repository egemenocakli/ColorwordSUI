//
//  UserWordListPickService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.07.2025.
//


protocol WordListSelectorInterface{
    func getWordGroups(for userInfo: UserInfoModel?) async throws -> [String]
    func getSharedWordGroups(for userInfo: UserInfoModel?) async throws -> [String]
}

class WordListSelectorService: WordListSelectorInterface {
    private let firestoreService = FirestoreService()

    func getWordGroups(for userInfo: UserInfoModel?) async throws -> [String] {
        var userWordGroups: [String] = []
        do{
          userWordGroups =  try await firestoreService.getWordGroups(userInfo: userInfo)
        }catch{
            throw error
        }
        guard !userWordGroups.isEmpty else {
            return []
        }
        return userWordGroups
    }
    
    func getSharedWordGroups(for userInfo: UserInfoModel?) async throws -> [String] {
        var userSharedWordGroups: [String] = []
        do{
          userSharedWordGroups =  try await firestoreService.getSharedWordGroups(userInfo: userInfo)
        }catch{
            throw error
        }
        guard !userSharedWordGroups.isEmpty else {
            return []
        }
        return userSharedWordGroups
    }
    
    
}

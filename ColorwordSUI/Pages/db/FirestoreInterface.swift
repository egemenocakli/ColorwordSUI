//
//  FirestoreInterface.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 12.11.2024.
//

import Foundation

//TODO: genel olarak tüm isteklerin sonucunda bool dönecek şekilde yap, bu cevaplardan gerekenleri ufak bildirim olarak göster
protocol FirestoreInterface {
    func getWordList() async throws -> [Word]
    func increaseWordScore(word: Word, points: Int) async throws
    func decreaseWordScore(word: Word, points: Int) async throws
    func createOrUpdateUserInfo(user: UserInfoModel, completion: @escaping (Bool) -> Void)
    func fetchUserInfo (userId: String, completion: @escaping (UserInfoModel?) -> Void)
    func increaseDailyPoints(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void)
    func resetDailyScore(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void)
    func changeDailyTarget(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void)
    func saveFavoriteLanguages(for languages: LanguageListWrapper,for userInfo: UserInfoModel?) async throws
    func getFavoriteLanguages(for userInfo: UserInfoModel?) async throws -> LanguageListWrapper
//    func addNewWord(word: Word, userInfo: UserInfoModel?) async throws
    func addNewWord(word: Word, userInfo: UserInfoModel?, selectedUserWordList: String?) async throws
    func getWordGroups(userInfo: UserInfoModel?) async throws -> [String]
    func deleteWordGroup(named languageListName: String,userInfo: UserInfoModel?) async throws
    func createWordGroup(languageListName: String,userInfo: UserInfoModel?) async throws
    func orderWordGroup(languageListName: String, userInfo: UserInfoModel?) async throws
}

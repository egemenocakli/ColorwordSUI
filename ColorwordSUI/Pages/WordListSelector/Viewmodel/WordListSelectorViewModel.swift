//
//  WordListSelectorViewmodel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.07.2025.
//

import Foundation

@MainActor
class WordListSelectorViewModel: ObservableObject {
    
    private let wordListSelectorService = WordListSelectorService()
    
    @Published var userWordGroups: [String] = []
    @Published var sharedWordGroups: [String] = []
    @Published var newWordGroupName: String = ""
    @Published var isUserReady: Bool = false


    init() {
        Task {
            await waitForUserInfoAndFetchLists()
        }
    }
    
    //TODO: burada kullanıcının oluşturduğu kelime listelerini silme ve hazır listelerden de yukarıya eklemek için butonlar eklenecek.
    func getWordGroupList(for userInfo: UserInfoModel) async {

        do {
            let groups = try await wordListSelectorService.getWordGroups(for: UserSessionManager.shared.userInfoModel)
                self.userWordGroups = groups
            
        }catch{
            debugPrint("Kelime Listeleri Alınamadı.")
        }
        
    }
    
    //TODO: englishA1LevelWordList diye kayıtlı şuan veri tabanında bunu daha düzgün tanımlamak lazım sadece English-> A1,A2,B1 vs. şeklinde başlangıç English olup içerisinde bunları tanımlayabilirim.
    func getSharedWordGroupList(for userInfo: UserInfoModel) async {
        
        do {
            let groups = try await wordListSelectorService.getSharedWordGroups(for: UserSessionManager.shared.userInfoModel)
                self.sharedWordGroups = groups
            
        }catch{
            debugPrint("Hazır Kelime Listeleri Alınamadı.")
        }
        
    }
    
    func createWordGroup(languageListName: String) async throws {
        
        guard let userInfoModel = UserSessionManager.shared.userInfoModel else {
            debugPrint("userInfoModel bulunamadı")
            return
        }
        
        do {
            try await wordListSelectorService.createWordGroup(languageListName: languageListName, userInfo: UserSessionManager.shared.userInfoModel)
            await getWordGroupList(for: userInfoModel)
        }catch {
            throw error
        }
    }
    
    func deleteWordGroup(languageListName: String) async throws {
        
        do {
            try await wordListSelectorService.deleteWordGroup(languageListName: languageListName, userInfo: UserSessionManager.shared.userInfoModel)
        }catch {
            throw error
        }
    }
    
func waitForUserInfoAndFetchLists() async {
        // 3 saniyeye kadar userInfoModel’in gelmesini bekle
        var attempts = 0
        while UserSessionManager.shared.userInfoModel == nil && attempts < 30 {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 saniye bekle
            attempts += 1
        }

        guard let userInfo = UserSessionManager.shared.userInfoModel else {
            print("User info yok, veriler getirilemedi")
            return
        }

        isUserReady = true
        await getWordGroupList(for: userInfo)
        await getSharedWordGroupList(for: userInfo)
    }
}

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

    
    
    //TODO: burada kullanıcının oluşturduğu kelime listelerini silme ve hazır listelerden de yukarıya eklemek için butonlar eklenecek.
    func getWordGroupList() async {
        
        do {
            let groups = try await wordListSelectorService.getWordGroups(for: UserSessionManager.shared.userInfoModel)
                self.userWordGroups = groups
            
        }catch{
            debugPrint("Kelime Listeleri Alınamadı.")
        }
        
    }
    
    //TODO: englishA1LevelWordList diye kayıtlı şuan veri tabanında bunu daha düzgün tanımlamak lazım sadece English-> A1,A2,B1 vs. şeklinde başlangıç English olup içerisinde bunları tanımlayabilirim.
    func getSharedWordGroupList() async {
        
        do {
            let groups = try await wordListSelectorService.getSharedWordGroups(for: UserSessionManager.shared.userInfoModel)
                self.sharedWordGroups = groups
            
        }catch{
            debugPrint("Hazır Kelime Listeleri Alınamadı.")
        }
        
    }
    
    func createWordGroup(languageListName: String) async throws {
        
        
        do {
            try await wordListSelectorService.createWordGroup(languageListName: languageListName, userInfo: UserSessionManager.shared.userInfoModel)
            await getWordGroupList()
        }catch {
            throw error
        }
    }
    
}

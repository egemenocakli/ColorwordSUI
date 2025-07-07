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
            debugPrint("Kelime Listeleri Alınamadı.")
        }
        
    }
}

//
//  HomeViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 6.02.2025.
//

import Foundation

final class HomeViewModel: ObservableObject {
    let homeService = HomeService()
    let userPreferences = UserPreferences()
    let keychainEncrpyter = KeychainEncrpyter()
    @Published var dailyProgressBarPoint: Int = 0
    @Published var loginSuccess: Bool = false

    //Burada autologinden userId içeriği henüz dolmadan fetchUserDailyPoint çağrılıyor o sebepten signletona çevirdim.
    static let shared = HomeViewModel()
    
    func changeLoginSuccesState () {
        loginSuccess = !loginSuccess
    }
    
    func signOut(completion: @escaping (Bool) -> Void) {
        homeService.signOut { response in
            if response {
                DispatchQueue.main.async {
                    self.userPreferences.savedEmail = ""
                    self.keychainEncrpyter.deletePassword()
                    self.loginSuccess = false 
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
    
    
    func fetchUserDailyPoint ()  {
       
        guard let userId =  UserSessionManager.shared.currentUser?.userId else {
            dailyProgressBarPoint = 0
            return
        }
        homeService.fetchUserDailyPoint(userId: userId) { userInfoModel in
            DispatchQueue.main.async {
                self.dailyProgressBarPoint = userInfoModel?.dailyScore ?? 0
            }
        }
    }
}

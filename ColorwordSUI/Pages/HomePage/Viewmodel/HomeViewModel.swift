//
//  HomeViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 6.02.2025.
//

import Foundation

class HomeViewModel: ObservableObject {
    let homeService = HomeService()
    let userPreferences = UserPreferences()
    let keychainEncrpyter = KeychainEncrpyter()
    
    func signOut() -> Bool {
        var result: Bool = false
        homeService.signOut { response in
            result = response
            
            if(result) {
                self.userPreferences.savedEmail = ""
                self.keychainEncrpyter.deletePassword()
            }
            
        }
        return result
    }
}

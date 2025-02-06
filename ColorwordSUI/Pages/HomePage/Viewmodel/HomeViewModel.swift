//
//  HomeViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 6.02.2025.
//

import Foundation

class HomeViewModel: ObservableObject {
    let homeService = HomeService()
    
    
    func signOut() -> Bool {
        var result: Bool = false
        homeService.signOut { response in
            result = response
        }
        return result
    }
}

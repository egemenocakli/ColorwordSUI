//
//  LoginViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.10.2024.
//

import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    
    @Published  var email: String = ""
    @Published  var password: String = ""
    
    
    func changeLanguage(to language: String, languageManager: LanguageManager) {
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.first?.rootViewController = UIHostingController(rootView: LoginScreen())
        }
        
        languageManager.currentLanguage = language
    }
    
}

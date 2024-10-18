//
//  LanguageManager.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 17.10.2024.
//

import SwiftUI
import Combine

class LanguageManager: ObservableObject {
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
    }
    
    init() {
        
        let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        let supportedLanguages = ["en", "tr"]

        if supportedLanguages.contains(deviceLanguage) {
            currentLanguage = deviceLanguage
        } else {
            currentLanguage = "en"
        }
    }
}

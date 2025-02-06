//
//  SignupScreen.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.10.2024.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        Text("welcome_to_signup").environment(\.locale, .init(identifier: languageManager.currentLanguage))
            
    }
}

#Preview {
    SignupView()
}

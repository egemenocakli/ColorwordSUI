//
//  SignupScreen.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.10.2024.
//

import SwiftUI

struct HomePageScreen: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        Text("homepage screen")//.environment(\.locale, .init(identifier: languageManager.currentLanguage))
            
    }
}

#Preview {
    HomePageScreen()
}

//
//  ColorwordSUIApp.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 17.10.2024.
//

import SwiftUI

@main
struct ColorwordSUIApp: App {
    
    @StateObject private var languageManager = LanguageManager()

    var body: some Scene {
        WindowGroup {
            LoginScreen()
                .environmentObject(languageManager)
        }
    }
}

//
//  ColorwordSUIApp.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 17.10.2024.
//

import SwiftUI
import FirebaseCore


@main
struct ColorwordSUIApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var languageManager = LanguageManager()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(languageManager)
                .environmentObject(themeManager)
        }
    }
}

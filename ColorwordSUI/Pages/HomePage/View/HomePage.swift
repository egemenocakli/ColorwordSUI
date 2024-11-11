//
//  SignupScreen.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.10.2024.
//

import SwiftUI

struct HomePage: View {
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var homepageVM = HomeViewModel()

    var body: some View {
        VStack {
            if let firstWord = homepageVM.wordList.first {
                Text("İlk Kelime: \(firstWord.word ?? "Yok")")
            } else {
                Text("Henüz veri yok.")
            }
        }
        .task {
            await homepageVM.getWordList()
        }
    }
}

#Preview {
    HomePage()
}

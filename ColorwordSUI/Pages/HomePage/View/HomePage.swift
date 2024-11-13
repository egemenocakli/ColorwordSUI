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

    @State private var selectedTabIndex = 0
    
    var body: some View {
        VStack {
                   if homepageVM.wordList.isEmpty {
                       Text("Henüz veri yok.")
                   } else {
                       TabView(selection: $selectedTabIndex) {
                           ForEach(Array(homepageVM.wordList.enumerated()), id: \.element.wordId) { index, word in
                               VStack {
                                   Text(word.word ?? "").fontWeight(.bold).font(.system(size: Constants.FontSizeConstants.x4Large))
                                   Text(word.translatedWords?.first ?? "").font(.system(size: Constants.FontSizeConstants.x3Large))
                                   Text(word.score != nil ? "\(word.score!)" : "")
                               }
                               .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                               .tag(index)
                           }
                       }
                       .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                       .onAppear {
                           if let firstWord = homepageVM.wordList.first {
                               homepageVM.getWordColorForBackground(word: firstWord)
                           }
                       }
                       .onChange(of: selectedTabIndex) { oldIndex, newIndex in
                           let word = homepageVM.wordList[newIndex]
                           homepageVM.getWordColorForBackground(word: word)
                      }
                   }
               }
               .background(Color(hex: homepageVM.wordBackgroundColor))
               .edgesIgnoringSafeArea(.all)
               .task {
                   await homepageVM.getWordList()
               }
           }
       
        
    //TODO: Dil eklentisi
}

//#Preview {
//    HomePage()
//}
//

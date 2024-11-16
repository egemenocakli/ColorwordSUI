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
        ZStack (alignment: .center){
            
            VStack {
            if homepageVM.wordList.isEmpty {
                Text("no_data").padding(.horizontal, Constants.PaddingSizeConstants.lmSize).frame(alignment: .center)
            } else {
                WordListTabView(selectedTabIndex: $selectedTabIndex,homePageVM: homepageVM)
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
        
            NextButtonWidgets(selectedTabIndex: $selectedTabIndex, homepageVM: homepageVM)
        }.environment(\.locale, .init(identifier: languageManager.currentLanguage))
    }
       
}

//#Preview {
//    HomePage()
//}
//

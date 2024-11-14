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
                Text("Henüz veri yok.")
            } else {
                TabView(selection: $selectedTabIndex) {
                    ForEach(Array(homepageVM.wordList.enumerated()), id: \.element.wordId) { index, word in
                        VStack {
                            Text(word.word ?? "").fontWeight(.bold).font(.system(size: Constants.FontSizeConstants.x4Large))
                            Text(word.translatedWords?.first ?? "").font(.system(size: Constants.FontSizeConstants.x3Large))
                            Text(word.score != nil ? "\(word.score!)" : "").font(.system(size: Constants.FontSizeConstants.xLarge))
                        }
                        .padding(.horizontal, 40)
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
        
            HStack {
                           Button {
                               
                               if selectedTabIndex > 0 {
                                   selectedTabIndex -= 1
                               }
                           } label: {
                               Image(systemName: Constants.IconTextConstants.leftButton)
                                   .resizable()
                                   .scaledToFit()
                                   .frame(width: Constants.FrameSizeConstants.smallSize, height: Constants.FrameSizeConstants.lSize)
                                   .padding(.leading, 10)
                                   .foregroundColor(selectedTabIndex == 0 ? .gray : .white.opacity(0.7))
                           }
                           .disabled(selectedTabIndex == 0)
                           
                Spacer()
                           
                           Button {
                              
                               if selectedTabIndex < homepageVM.wordList.count - 1 {
                                   selectedTabIndex += 1
                               }
                           } label: {
                               Image(systemName: Constants.IconTextConstants.rightButton)
                                   .resizable()
                                   .scaledToFit()
                                   .frame(width: Constants.FrameSizeConstants.smallSize, height: Constants.FrameSizeConstants.lSize)
                                   .padding(.trailing, 10)
                                   .foregroundColor(selectedTabIndex == homepageVM.wordList.count - 1 ? .gray : .white.opacity(0.7)) 
                           }
                           .disabled(selectedTabIndex == homepageVM.wordList.count - 1)
                       }
        }
}
       
        
    //TODO: Dil eklentisi
}

//#Preview {
//    HomePage()
//}
//

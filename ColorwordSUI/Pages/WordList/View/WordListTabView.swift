//
//  TabView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 16.11.2024.
//

import SwiftUI

struct WordListTabView: View {
    @Binding var selectedTabIndex: Int
    @ObservedObject var wordListVM: WordListViewModel
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            ForEach(Array(wordListVM.wordList.enumerated()), id: \.element.wordId) { index, word in
                VStack {
                    Text(word.word ?? "")
                        .fontWeight(.bold)
                        .font(.system(size: Constants.FontSizeConstants.x4Large))
                        .foregroundStyle(Color.textColorWhite)
                    
                    Text(word.translatedWords?.first ?? "")
                        .font(.system(size: Constants.FontSizeConstants.x3Large))
                        .foregroundStyle(Color.textColorWhite)
                    
                    Text(word.score != nil ? "\(word.score!)" : "")
                        .font(.system(size: Constants.FontSizeConstants.xLarge))
                    .foregroundStyle(Color.textColorWhite)
                }
                .padding(.horizontal, Constants.PaddingSizeConstants.lmSize)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

#Preview {
    WordListTabView(selectedTabIndex: .constant(0), wordListVM: WordListViewModel())
}

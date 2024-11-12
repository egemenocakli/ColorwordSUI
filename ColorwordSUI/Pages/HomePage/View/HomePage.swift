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
            if homepageVM.wordList.isEmpty {
                Text("Henüz veri yok.")
            } else {
                TabView {
                    ForEach(homepageVM.wordList, id: \.wordId) { word in
                        VStack {
                            Text(word.word ?? "")
                            Text(word.translatedWords?.first ?? "")
                        }
                        //TODO: Bir hata var burada tam kaydırılmasa bile renk değiştiriyor.
                        .onAppear(){
                            let backgroudColor = word.color?.toHex() ?? "#000000"
                            homepageVM.wordBackgroundColor = backgroudColor
                        }
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }.background(Color(hex:homepageVM.wordBackgroundColor))
        .task {
            await homepageVM.getWordList()
        }
        
    }
}

#Preview {
    HomePage()
}




//import SwiftUI
//
//struct HomePage: View {
//    @EnvironmentObject var languageManager: LanguageManager
//    @StateObject private var homepageVM = HomeViewModel()
//
//    var body: some View {
//        
//        ScrollView(.horizontal) {
//            VStack {
//                if let firstWord = homepageVM.wordList.first {
//                Text(firstWord.word ?? "")
//                Text(firstWord.translatedWords?.first ?? "")
//                 } else {
//                    Text("Henüz veri yok.")
//                    }
//                }
//                    .task {
//                        await homepageVM.getWordList()
//            }
//        }.frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
//
//    }
//}
//
//#Preview {
//    HomePage()
//}
//        VStack {
//            if let firstWord = homepageVM.wordList.first {
//                Text(firstWord.word ?? "")
//                Text(firstWord.translatedWords?.first ?? "")
//            } else {
//                Text("Henüz veri yok.")
//            }
//        }
//        .task {
//            await homepageVM.getWordList()
//        }

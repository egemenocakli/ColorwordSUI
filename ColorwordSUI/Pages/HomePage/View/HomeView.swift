//
//  SignupScreen.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.10.2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var homeVM = HomeViewModel()
    @EnvironmentObject var themeManager: ThemeManager

    @State private var selectedTabIndex = 0
    @State private var navigateToLogin = false // Yönlendirme kontrolü
    @State private var selectedTab = 0 // TabView için seçili index

    var body: some View {
        ZStack (alignment: .center){
            
            VStack {
            //Loading belki yüklenmezse bu uyarı yazılabilir.
            if homeVM.wordList.isEmpty {
                Text("no_data").padding(.horizontal, Constants.PaddingSizeConstants.lmSize).frame(alignment: .center)
                    .background(Color.white.opacity(0.00))
            } else {
                WordListTabView(selectedTabIndex: $selectedTabIndex,homePageVM: homeVM)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onAppear {
                    if let firstWord = homeVM.wordList.first {
                        homeVM.getWordColorForBackground(word: firstWord,themeManager: themeManager)
                    }
                }
                .onChange(of: selectedTabIndex) { oldIndex, newIndex in
                    let word = homeVM.wordList[newIndex]
                    homeVM.getWordColorForBackground(word: word,themeManager: themeManager)
                }
            }
                //TODO: Bu buton bu sayfada gereksiz, profil veya ayarlar gibi bir yerde olmalı. Taşınacak
                //Çıkışta veriler silinecek
                Button {
                    if homeVM.signOut() == true {
                        navigateToLogin = true 
                    }else {
                        
                    }
                }
                label: {
                    Text("Çıkış")
                }.padding(.bottom, Constants.PaddingSizeConstants.lmSize).frame(alignment: .center)
                    .background(Color.white.opacity(0.00))

        }
        .background(Color(hex: homeVM.wordBackgroundColor))
        .edgesIgnoringSafeArea(.all)
        .task {
            await homeVM.getWordList()
        }
        
            NextButtonWidgets(selectedTabIndex: $selectedTabIndex, homeVM: homeVM)
        }
        .environment(\.locale, .init(identifier: languageManager.currentLanguage))
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginView().navigationBarBackButtonHidden(true)
            
        }
        
    }
    
}

//#Preview {
//    
//    HomeView().environmentObject(LanguageManager())
//
//}


//
//  SignupScreen.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.10.2024.
//

import SwiftUI

struct WordListView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var wordListVM = WordListViewModel()
    @EnvironmentObject var themeManager: ThemeManager

    @State private var selectedTabIndex = 0
    @State private var navigateToLogin = false 
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            ZStack (alignment: .center){
            
                VStack {
                    //Loading gösterilebilir hatta yüklenmezse bu uyarı yazılabilir.
                    if wordListVM.wordList.isEmpty {
                        Text("no_data").padding(.horizontal, Constants.PaddingSizeConstants.lmSize).frame(alignment: .center)
                            .background(Color.white.opacity(0.00))
                    } else {
                        WordListTabView(selectedTabIndex: $selectedTabIndex,wordListVM: wordListVM)
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .onAppear {
                                if let firstWord = wordListVM.wordList.first {
                                    wordListVM.getWordColorForBackground(word: firstWord,themeManager: themeManager)
                                }
                            }
                            .onChange(of: selectedTabIndex) { oldIndex, newIndex in
                                let word = wordListVM.wordList[newIndex]
                                wordListVM.getWordColorForBackground(word: word,themeManager: themeManager)
                            }
                    }
                    //TODO: Bu buton bu sayfada gereksiz, profil veya ayarlar gibi bir yerde olmalı. Taşınacak
                    //Çıkışta veriler silinecek
                    Button {
                        if wordListVM.signOut() == true {
                            navigateToLogin = true
                        }else {
                            
                        }
                    }
                    label: {
                        Text("Çıkış")
                    }.padding(.bottom, Constants.PaddingSizeConstants.lmSize).frame(alignment: .center)
                        .background(Color.white.opacity(0.00))
                    NavigationLink(destination: MchoiceTestView()) {
                                        Text("Test Sayfasına Git")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(.white.opacity(0.3))
                                            .cornerRadius(Constants.SizeRadiusConstants.medium)
                    }.padding(.bottom, 30)
                    
                }
                .background(Color(hex: wordListVM.wordBackgroundColor))
                .edgesIgnoringSafeArea(.all)
                .task {
                    await wordListVM.getWordList()
                }
                
                NextButtonWidgets(selectedTabIndex: $selectedTabIndex, wordListVM: wordListVM)
            }
            .environment(\.locale, .init(identifier: languageManager.currentLanguage))
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView().navigationBarBackButtonHidden(true)
                
            }
        }
    }
    
}

//#Preview {
//    
//    HomeView().environmentObject(LanguageManager())
//
//}


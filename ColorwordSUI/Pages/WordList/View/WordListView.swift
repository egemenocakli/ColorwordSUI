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
    let selectedWordListName: String

    @State private var selectedTabIndex = 0
    @State private var navigateToLogin = false
    @State private var selectedTab = 0
    @State private var showAddWordView = false

    //TODO: geometry eklenecek
    var body: some View {
        NavigationView {
            ZStack (alignment: .center){
                Color(hex: wordListVM.wordBackgroundColor)
                    .animation(.easeInOut(duration: Constants.TimerTypeConstants.standardSpringAnimation), value: wordListVM.wordBackgroundColor)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    //Loading gösterilebilir hatta yüklenmezse bu uyarı yazılabilir.
                    if wordListVM.wordList.isEmpty {
                        ProgressView("loading")
                            .progressViewStyle(CircularProgressViewStyle(tint: Constants.ColorConstants.whiteColor))
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


                }
                .background(
                    Color(Color(hex: wordListVM.wordBackgroundColor)!)
                        .animation(.easeInOut(duration: Constants.TimerTypeConstants.standardSpringAnimation), value: Color(hex: wordListVM.wordBackgroundColor))
                )                .edgesIgnoringSafeArea(.all)
                .task {
                    await wordListVM.getWordList(wordListName: selectedWordListName)
                }
                
                //TODO: constants vs düzenlenecek.
                //button genel bir fab buton olarak common widgets için eklenebilir.
                VStack {
                    
                    Spacer()
                    FabButton(action: {
                        showAddWordView = true

                    }, backgroundColor: .addFabButton,
                        foregroundColor: Constants.ColorConstants.buttonForegroundColor,
                        cornerRadius: Constants.SizeRadiusConstants.medium,
                        buttonImageName: Constants.IconTextConstants.addButtonRectangle)
                    

                        .navigationDestination(isPresented: $showAddWordView) {
                            if #available(iOS 18.0, *) {
                                AddNewWordView(selectedWordList: selectedWordListName)
                            } else {

                            }
                        }
                    


                    FabButton(action: {
                        //TODO: silme eklenecek. alert ile silmeden önce sorulacak.
                    }, backgroundColor: .deleteFabButton,
                        foregroundColor: Constants.ColorConstants.buttonForegroundColor,
                        cornerRadius: Constants.SizeRadiusConstants.medium,
                        buttonImageName: Constants.IconTextConstants.deleteButtonRectangle)
                    
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


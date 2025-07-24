//
//  UserWordListPickView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.07.2025.
//

import SwiftUI

struct WordListSelectorView: View {
    
    @StateObject var wordListSelectorVM = WordListSelectorViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    let selectedTargetPage: String
    
    @State private  var showAddNewWordGroupWidget = false
    @State private  var showDeleteWordGroupWidget = false

    
    //TODO: renkler constantstan alınacak ve localization eklencek.
    var body: some View {
        GeometryReader { geometry in
            
            NavigationStack {
                ZStack{
                    Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)
                    ScrollView {
                        
                        if (wordListSelectorVM.isUserReady == false && wordListSelectorVM.userWordGroups.count == 0) {
                            ProgressView("loading")
                                .progressViewStyle(CircularProgressViewStyle(tint: Constants.ColorConstants.whiteColor))
                                .padding(.top, geometry.size.height * 0.3)
                                .task {
                                    Task{
                                        try await wordListSelectorVM.createWordGroup(languageListName: "wordLists")
                                    }
                                }
                            
                        }else {
                            VStack(alignment: .leading, spacing: Constants.PaddingSizeConstants.smallSize) {
                                
                                if(showAddNewWordGroupWidget == true) {
                                    WordListCreateNewWordGroup(wordListSelectorVM: wordListSelectorVM, showNewWordGroupWidget: $showAddNewWordGroupWidget)
                                        .padding(.horizontal)
                                }else {
                                    // Liste 1
                                    Text("your_custom_word_list")
                                        .foregroundStyle(Color(.textColorW))
                                        .font(.title2).bold()
                                        .padding(.leading)
                                }
                                
                                ForEach(wordListSelectorVM.userWordGroups, id: \.self) { groupName in
                                    let displayText: LocalizedStringKey = groupName == "wordLists" ? "word_lists" : LocalizedStringKey(groupName)
                                    
                                    HStack {
                                        NavigationLink(destination: getDestinationView(groupName: groupName)) {
                                            Text(displayText)
                                                .padding()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color.wordListSelectorCardColor)
                                                .cornerRadius(Constants.SizeRadiusConstants.xxSmall)
                                                .padding(.horizontal)
                                                .foregroundStyle(Color(.textColorW))
                                        }
                                        
                                        
                                        if (showDeleteWordGroupWidget == true) {
                                            
                                            IconButton(iconName: Constants.IconTextConstants.deleteButtonRectangle, backgroundColor: .translateButton, foregroundColor: Constants.ColorConstants.buttonForegroundColor, frameWidth: 24, frameHeight: 24, paddingEdge: .trailing, paddingValue: 8, radius: Constants.SizeRadiusConstants.xSmall) {
                                                
                                                Task {
                                                    do{
                                                        withAnimation {
                                                            wordListSelectorVM.userWordGroups.removeAll { $0 == groupName }
                                                        }
                                                        try await wordListSelectorVM.deleteWordGroup(languageListName: groupName)
                                                        await wordListSelectorVM.waitForUserInfoAndFetchLists()
                                                        
                                                    }catch{
                                                        throw error
                                                    }
                                                }
                                            }
                                            
                                        }else {
                                            EmptyView()
                                            }
                                        }
                                    }
                                
                            }
                            .padding(.vertical)
                            .animation(.easeInOut, value: wordListSelectorVM.userWordGroups)
                            
                            // Hazır Kelime Listeleri
                            VStack(alignment: .leading, spacing: Constants.PaddingSizeConstants.smallSize) {
                                Text("predefined_word_list")
                                    .font(.title2).bold()
                                    .padding(.leading)
                                    .foregroundStyle(Color(.textColorW))

                                ForEach(wordListSelectorVM.sharedWordGroups, id: \.self) { groupName in
                                    Text(groupName)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.wordListSelectorSharedCardColor)
                                        .cornerRadius(Constants.SizeRadiusConstants.xxSmall)
                                        .padding(.horizontal)
                                        .foregroundStyle(Color(.textColorW))
                                }
                            }
       
                }
            }

                    VStack {
                        
                        Spacer()
                        FabButton(action: {
                            showAddNewWordGroupWidget = !showAddNewWordGroupWidget
                            
                        }, backgroundColor: .addFabButton,
                                  foregroundColor: Constants.ColorConstants.buttonForegroundColor,
                                  cornerRadius: Constants.SizeRadiusConstants.medium,
                                  buttonImageName: Constants.IconTextConstants.addButtonRectangle)
                        
                        
                        
                        FabButton(action: {
                            //TODO: silme eklenecek. alert ile silmeden önce sorulacak.
                            showDeleteWordGroupWidget = !showDeleteWordGroupWidget
                            
                        }, backgroundColor: .deleteFabButton,
                                  foregroundColor: Constants.ColorConstants.buttonForegroundColor,
                                  cornerRadius: Constants.SizeRadiusConstants.medium,
                                  buttonImageName: Constants.IconTextConstants.deleteButtonRectangle)
                        
                    }
                    
                }
                .animation(.easeInOut, value: showDeleteWordGroupWidget)
                .animation(.easeInOut, value: showAddNewWordGroupWidget)
                
            }
        }
        .environment(\.locale, .init(identifier: languageManager.currentLanguage))

    }
    private func getDestinationView(groupName: String) -> AnyView {
        if selectedTargetPage == "wordList" {
            return AnyView(WordListView(selectedWordListName: groupName))
        } else if selectedTargetPage == "multipleChoiceTest" {
            return AnyView(MchoiceTestView(selectedWordListName: groupName))
        } else {
            // Varsayılan view — istersen boş bir view de koyabilirsin
            return AnyView(EmptyView())
        }
    }

}


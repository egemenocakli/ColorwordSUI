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

//    ///HomeView sayfasında tıklanılan butonların sonraki adımlarında hangi sayfaya yönlendirileceklerini tutan değişken.
//    enum TargetPage: String {
//        case wordList = "wordList"
//        case multipleChoiceTest = "multipleChoiceTest"
//    }
    

    
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
                            VStack(alignment: .leading, spacing: 24) {
                                
                                if(showAddNewWordGroupWidget == true) {
                                    WordListCreateNewWordGroup(wordListSelectorVM: wordListSelectorVM, showNewWordGroupWidget: $showAddNewWordGroupWidget)
                                        .padding(.horizontal)
                                }else {
                                    // Liste 1
                                    Text("Sizin Oluşturduğunuz Kelime Listeleri")
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
                                                .cornerRadius(8)
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
                            Text("Hazır Kelime Listeleri")
                                .font(.title2).bold()
                                .padding(.leading)
                                .foregroundStyle(Color(.textColorW))
                            
                            
                            ForEach(wordListSelectorVM.sharedWordGroups, id: \.self) { groupName in
                                Text(groupName)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.wordListSelectorSharedCardColor)
                                
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .foregroundStyle(Color(.textColorW))
                                
                            }
                            
                            
                            
                        
                        
                    
                }
            }

                    
                    
                    
                    VStack {
                        
                        Spacer()
                        FabButton(action: {
                            
                            //TODO: yine aynı şekilde ekle butonuna basınca da en üstte bir alan açılacak buraya yazılan text ile yeni liste açabilecek.
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


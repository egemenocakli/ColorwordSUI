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
    
    @State private  var showAddNewWordGroupWidget = false
    @State private  var showDeleteWordGroupWidget = false

    
    //TODO: renkler constantstan alınacak ve localization eklencek.
    var body: some View {
        GeometryReader { geometry in
            
            NavigationStack {
                ZStack{
                    Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)
                    ScrollView {
                        
                        if wordListSelectorVM.isUserReady == false {
                            ProgressView("loading")
                                .progressViewStyle(CircularProgressViewStyle(tint: Constants.ColorConstants.whiteColor))
                                .padding(.top, geometry.size.height * 0.3)
                            
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
                                    NavigationLink(destination: WordListView(wordListName: groupName)) {

                                        HStack{
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
                            .padding(.vertical)
                            .animation(.easeInOut, value: wordListSelectorVM.userWordGroups)
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
}

#Preview {
    WordListSelectorView()
}

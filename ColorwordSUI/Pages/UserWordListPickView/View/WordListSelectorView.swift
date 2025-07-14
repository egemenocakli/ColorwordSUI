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

    var body: some View {
        NavigationStack {
            ZStack{
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        
                        
                    //TODO: yeni kelime listesi oluşturma
                    //TODO: şu en çok kullandığım iconButton olarak common a eklenecek.
                        
                        if(showAddNewWordGroupWidget == true) {
                            WordListCreateNewWordGroup(wordListSelectorVM: wordListSelectorVM, showNewWordGroupWidget: $showAddNewWordGroupWidget)
                                .padding(.horizontal)
                        }else {
                            // Liste 1
                            Text("Sizin Oluşturduğunuz Kelime Listeleri")
                                .font(.title2).bold()
                                .padding(.leading)
                        }
                        
                        ForEach(wordListSelectorVM.userWordGroups, id: \.self) { groupName in
                            
                            HStack{
                                Text(groupName)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                
                                
                                if (showDeleteWordGroupWidget == true) {
                                    
                                    IconButton(iconName: Constants.IconTextConstants.deleteButtonRectangle, backgroundColor: .translateButton, foregroundColor: Constants.ColorConstants.buttonForegroundColor, frameWidth: 24, frameHeight: 24, paddingEdge: .trailing, paddingValue: 8, radius: Constants.SizeRadiusConstants.xSmall) {
                                        
                                        Task {
                                            do{
                                                withAnimation {
                                                        wordListSelectorVM.userWordGroups.removeAll { $0 == groupName }
                                                        }
                                                try await wordListSelectorVM.deleteWordGroup(languageListName: groupName)
                                                await wordListSelectorVM.getWordGroupList()
                                                
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
                        
                        // Liste 2
                        Text("Hazır Kelime Listeleri")
                            .font(.title2).bold()
                            .padding(.leading)
                        
                        ForEach(wordListSelectorVM.sharedWordGroups, id: \.self) { groupName in
                            Text(groupName)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal)

                        }
                    }
                    .padding(.vertical)
                    .animation(.easeInOut, value: wordListSelectorVM.userWordGroups)
                    
                    
                    
                }
                .onAppear{
                    Task {
                        await wordListSelectorVM.getWordGroupList()
                        await wordListSelectorVM.getSharedWordGroupList()
                    }
                }
                .navigationTitle("Kelime Listeleri")
                
                
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

#Preview {
    WordListSelectorView()
}

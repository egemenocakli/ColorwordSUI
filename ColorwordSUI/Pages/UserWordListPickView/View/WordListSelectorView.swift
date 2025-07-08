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
                                    Button(action: {
                                        //Delete işlemi
                                    } ) {
                                        Image(systemName: Constants.IconTextConstants.deleteButtonRectangle)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .padding(8)
                                    }
                                    .foregroundStyle(Constants.ColorConstants.buttonForegroundColor)
                                    .background(.translateButton)
                                    .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xSmall))
                                    .shadow(radius: Constants.SizeRadiusConstants.xSmall)
                                    .padding(.trailing, 8)
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

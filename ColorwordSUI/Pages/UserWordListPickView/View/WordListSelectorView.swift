//
//  UserWordListPickView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.07.2025.
//

import SwiftUI

struct WordListSelectorView: View {
    
    @StateObject var wordListSelectorVM = WordListSelectorViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack{
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Liste 1
                        Text("Sizin Oluşturduğunuz Kelime Listeleri")
                            .font(.title2).bold()
                            .padding(.leading)
                        
                        ForEach(wordListSelectorVM.userWordGroups, id: \.self) { groupName in
                            Text(groupName)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            
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
            }
        }
    }
}

#Preview {
    WordListSelectorView()
}

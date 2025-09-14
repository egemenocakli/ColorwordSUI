//
//  WordListCreateNewWordGroup.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 9.07.2025.
//

import SwiftUI

struct WordListCreateNewWordGroup: View {

        @ObservedObject var wordListSelectorVM: WordListSelectorViewModel
        @Binding var showNewWordGroupWidget: Bool
        @EnvironmentObject var languageManager: LanguageManager
        
        var body: some View {
            
            Text("enter_new_word_list_name")
                .font(.system(size: Constants.FontSizeConstants.xLarge))
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            HStack{
                //TODO: bu text editorler common widgeta eklenecek
                
                TextEditor(text: $wordListSelectorVM.newWordGroupName)
                    .fontWeight(.bold)
                    .font(.system(size: Constants.FontSizeConstants.large))
                    .foregroundStyle(Color.textColorWhite)
                    .padding(Constants.PaddingSizeConstants.xsmallSize)
                    .scrollContentBackground(.hidden)
                    .background(Color.white.opacity(0.05).blur(radius: Constants.SizeRadiusConstants.textEditorRadius))
                    .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
                    .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
//                    .padding(.all, Constants.PaddingSizeConstants.xxSmallSize)
                    .padding(.trailing, Constants.PaddingSizeConstants.xxSmallSize)
                    .frame(minHeight: Constants.FrameSizeConstants.xLSize, maxHeight: Constants.FrameSizeConstants.xLSize)
                    .limitTextEditorCharacters($wordListSelectorVM.newWordGroupName, limit: 15)
                
                
                Button(action: {

                    if(!wordListSelectorVM.newWordGroupName.isEmpty){
                    
                        Task{
                                do {
                                    try await wordListSelectorVM.createWordGroup(languageListName: wordListSelectorVM.newWordGroupName)
                                wordListSelectorVM.newWordGroupName = ""
                    
                                }catch {
                                debugPrint("Yeni kelime grubu eklenemedi")
                                wordListSelectorVM.newWordGroupName = ""
                            }
                    
                            showNewWordGroupWidget = false
                        }
                    }
                    
                } ) {
                    Image(systemName: Constants.IconTextConstants.correctBasicButton)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.IconSizeConstants.xSmallSize, height: Constants.IconSizeConstants.xSmallSize)
                    .padding(Constants.PaddingSizeConstants.xxxSmallSize)
                }
                .foregroundStyle(Constants.ColorConstants.buttonForegroundColor)
                .background(.addFabButton)
                .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xSmall))
                .shadow(radius: Constants.SizeRadiusConstants.xSmall)
                
                Button(action: {

                    showNewWordGroupWidget = false
                    
                }) {
                    Image(systemName: Constants.IconTextConstants.xmarkBasicButton)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.IconSizeConstants.xSmallSize, height: Constants.IconSizeConstants.xSmallSize)
                    .padding(Constants.PaddingSizeConstants.xxxSmallSize)
                }
                .foregroundStyle(Constants.ColorConstants.buttonForegroundColor)
                .background(.deleteFabButton)
                .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xSmall))
                .shadow(radius: Constants.SizeRadiusConstants.xSmall)
            
        }
    }

}

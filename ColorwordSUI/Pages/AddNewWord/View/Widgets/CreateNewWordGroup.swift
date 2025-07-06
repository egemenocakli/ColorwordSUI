//
//  CreateNewWordGroup.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 23.06.2025.
//

import SwiftUI

struct CreateNewWordGroup: View {
    @ObservedObject var addNewWordVM: AddNewWordViewModel
    @Binding var showNewWordGroupWidget: Bool
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        
        Text("enter_new_word_list_name")
            .font(.system(size: Constants.FontSizeConstants.xLarge))
            .fontWeight(.bold)
            .foregroundStyle(.white)
        
        HStack{
            //TODO: bu text editorler common widgeta eklenecek
            
            TextEditor(text: $addNewWordVM.newWordGroupName)
                .fontWeight(.bold)
                .font(.system(size: Constants.FontSizeConstants.large))
                .foregroundStyle(Color.textColorWhite)
                .padding(Constants.PaddingSizeConstants.xsmallSize)
                .scrollContentBackground(.hidden)
                .background(Color.white.opacity(0.05).blur(radius: Constants.SizeRadiusConstants.textEditorRadius))
                .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
                .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
                .padding(.all, Constants.PaddingSizeConstants.xxSmallSize)
                .padding(.trailing, Constants.PaddingSizeConstants.xxSmallSize)
                .frame(minHeight: 40, maxHeight: 70)
                .limitTextEditorCharacters($addNewWordVM.newWordGroupName, limit: 15)
            
            
            
            Button( action:  {
                if(!addNewWordVM.newWordGroupName.isEmpty){
                    
                    Task{
                        do {
                            try await addNewWordVM.createWordGroup(languageListName: addNewWordVM.newWordGroupName)
                            addNewWordVM.newWordGroupName = ""
                            
                        }catch {
                            debugPrint("Yeni kelime grubu eklenemedi")
                            addNewWordVM.newWordGroupName = ""
                        }
                        
                        showNewWordGroupWidget = false
                    }
                }
                
            }) {
                Image(systemName: Constants.IconTextConstants.correctFillButton)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.IconSizeConstants.mSize, height: Constants.IconSizeConstants.mSize)
                    .foregroundColor(.addFabButton)
                    .background(Constants.ColorConstants.buttonForegroundColor)
                    .clipShape(Circle())
            }
            .padding(.trailing, Constants.PaddingSizeConstants.xxxSmallSize)
            
            Button( action:  {
                showNewWordGroupWidget = false
            }) {
                Image(systemName: Constants.IconTextConstants.wrongButtonCircleFill)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.IconSizeConstants.mSize, height: Constants.IconSizeConstants.mSize)
                    .foregroundColor(.deleteFabButton)
                    .background(Constants.ColorConstants.buttonForegroundColor)
                    .clipShape(Circle())
                
            }
            .padding(.trailing, Constants.PaddingSizeConstants.xsmallSize)
            
            
        }
    }
}

//#Preview {
//    CreateNewWordGroup()
//}

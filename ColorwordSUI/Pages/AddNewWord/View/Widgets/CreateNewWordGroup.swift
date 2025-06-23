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
            .font(.system(size: 20))
            .fontWeight(.bold)
            .foregroundStyle(.white)
        
        HStack{
            //TODO: bu text editorler common widgeta eklenecek
            
            TextEditor(text: $addNewWordVM.newWordGroupName)
                .fontWeight(.bold)
                .font(.system(size: Constants.FontSizeConstants.large))
                .foregroundStyle(Color.textColorWhite)
                .padding(16)
                .scrollContentBackground(.hidden)
                .background(Color.white.opacity(0.05).blur(radius: 50))
                .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
                .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
                .padding(.all, Constants.PaddingSizeConstants.xSmallSize)
                .padding(.trailing, 10)
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
                    .frame(width: 32, height: 32)
                    .foregroundColor(.green)
                    .background(.white)
                    .clipShape(Circle())
            }
            .padding(.trailing, 8)
            
            Button( action:  {
                showNewWordGroupWidget = false
            }) {
                Image(systemName: Constants.IconTextConstants.wrongButtonCircleFill)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.red)
                    .background(.white)
                    .clipShape(Circle())
                
            }
            .padding(.trailing, 16)
            
            
        }
    }
}

//#Preview {
//    CreateNewWordGroup()
//}

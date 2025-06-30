//
//  TranslateTextEditorWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 30.06.2025.
//

import SwiftUI


struct TranslateTextEditorWidget: View {
    @ObservedObject var addNewWordVM: AddNewWordViewModel
    
    var body: some View {

        
        TextEditor(text: $addNewWordVM.enteredWord)
            .fontWeight(.bold)
            .font(.system(size: Constants.FontSizeConstants.x2Large))
            .foregroundStyle(Color.textColorWhite)
            .padding(12)
            .scrollContentBackground(.hidden)
            .background(Color.white.opacity(0.05).blur(radius: 50))
            .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
            .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
            .padding(.all, Constants.PaddingSizeConstants.xSmallSize)
            .frame(minHeight: 60, maxHeight: 110)
            .limitTextEditorCharacters($addNewWordVM.enteredWord, limit: 40)
        
    }
    

}


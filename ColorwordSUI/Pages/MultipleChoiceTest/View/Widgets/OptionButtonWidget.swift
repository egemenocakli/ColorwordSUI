//
//  OptionButtonWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 29.11.2024.
//

import SwiftUI

struct OptionButtonWidget: View {
    var selectedButton: Int
    var viewModel: MchoiceTestViewModel
//    var action: () -> Void
    var onPageQuestion: QuestModel?

    var body: some View {
        Button(action: {

            
            viewModel.checkAnswerAndUpdateButtonState(quest: onPageQuestion, selectedButton: selectedButton)

            
        }) {
            Text(onPageQuestion!.options[selectedButton].optionText + " (\(onPageQuestion!.options[selectedButton].optionState))")
                .padding()
                .foregroundColor(.white)
                .background(.white.opacity(0.1))
                .cornerRadius(100)
        }
        .padding(.all, 10)
    }
}


//Button(action: {
//    mchoiceTestVM.checkAnswerAndUpdateButtonState(quest: $onPageQuestion, selectedButton: 0)
//    
//}) {
//  Text($onPageQuestion.options[0].optionText + " (\($onPageQuestion.options[0].optionState))")
//    .padding()
//    .foregroundColor(.white)
//    .background(.white.opacity(0.1))
//    .cornerRadius(100)
//}
//.padding(.all, 10)

//#Preview {
//    OptionButtonWidget()
//}

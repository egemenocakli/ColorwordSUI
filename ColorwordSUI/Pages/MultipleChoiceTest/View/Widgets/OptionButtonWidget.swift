//
//  OptionButtonWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 29.11.2024.
//

import SwiftUI

struct OptionButtonWidget: View {
    
    var action: () -> Void
    var initialQuestion: Binding<QuestModel>
    @Binding var backgroundColor: Color // Renk değişimlerini reaktif hale getirmek için Binding
    var buttonIndex: Int

    var body: some View {
        Button(action: action) {
            Text(initialQuestion.options[buttonIndex].wrappedValue.optionText + " (\(initialQuestion.options[buttonIndex].wrappedValue.optionState))")
                .padding()
                .foregroundColor(.white)
                .background(backgroundColor)
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

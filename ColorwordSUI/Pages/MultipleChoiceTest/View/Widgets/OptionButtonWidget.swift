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
    @Binding var backgroundColor: Color
    var buttonIndex: Int
    @State private var opacity: Double = 1
    @State private var timeRemaining = 1
    let timer = Timer.publish(every: 0.7, on: .main, in: .common).autoconnect()

    var body: some View {
        Button(action: action) {
            Text(initialQuestion.options[buttonIndex].wrappedValue.optionText)
//                 + " (\(initialQuestion.options[buttonIndex].wrappedValue.optionState))")
                .padding()
                .foregroundColor(.white)
                .background(backgroundColor)
                .cornerRadius(100)
        }.onReceive(timer) { time in
            if timeRemaining > 0 {
                    timeRemaining -= 1
                }
            else if(timeRemaining == 0 && initialQuestion.options[buttonIndex].wrappedValue.optionState == .wrong){
                withAnimation(.easeInOut(duration: 1)) {
                    opacity = 0
                  }
                timer.upstream.connect().cancel()
            }
        }
        .opacity(opacity)
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

//
//  MchoiceTestView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 22.11.2024.
//

import SwiftUI

struct MchoiceTestView: View {
    @StateObject var mchoiceTestVM = MchoiceTestViewModel()
    @State private var selectedTabIndex = 0
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var buttonColor: Color = .white
    @State private var buttonColor2: Color = .white
    @State private var buttonColor3: Color = .white
    @State private var buttonColor4: Color = .white
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack {
                // Loading göstergesi
                if mchoiceTestVM.wordList.isEmpty {
                    Text("no_data")
                        .padding(.horizontal, Constants.PaddingSizeConstants.lmSize)
                        .frame(alignment: .center)
                        .background(Color.white.opacity(0.00))
                } else {
                    VStack {
                        TabView(selection: $selectedTabIndex) {
                            ForEach(Array(mchoiceTestVM.questList.enumerated()), id: \.element.word.wordId) { index, onPageQuestion in
                                VStack {
                                    Text(onPageQuestion.word.word ?? "")
                                        .fontWeight(.bold)
                                        .font(.system(size: Constants.FontSizeConstants.x4Large))
                                        .foregroundStyle(Color.textColorWhite)
                                    
                                    Text(onPageQuestion.word.translatedWords?.first ?? "")
                                        .font(.system(size: Constants.FontSizeConstants.x3Large))
                                        .foregroundStyle(Color.textColorWhite)
                                    
                                    // Binding oluşturma
                                    choiceButtons(initialQuestion: .constant(onPageQuestion))
                                }
                                .padding(.horizontal, Constants.PaddingSizeConstants.lmSize)
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .onAppear {
                            if let firstWord = mchoiceTestVM.wordList.first {
                                mchoiceTestVM.getWordColorForBackground(word: firstWord, themeManager: themeManager)
                            }
                        }
                        .onChange(of: selectedTabIndex) { oldIndex, newIndex in
                            let word = mchoiceTestVM.wordList[newIndex]
                            mchoiceTestVM.getWordColorForBackground(word: word, themeManager: themeManager)
                            buttonColor = .white.opacity(0.1)
                            buttonColor2 = .white.opacity(0.1)
                            buttonColor3 = .white.opacity(0.1)
                            buttonColor4 = .white.opacity(0.1)
                        }
                    }
                }
            }
            .background(Color(hex: mchoiceTestVM.wordBackgroundColor))
            .edgesIgnoringSafeArea(.all)
            .task {
                mchoiceTestVM.questList = await mchoiceTestVM.createThreeUniqueOption()
            }
        }
    }
    
//    private func choiceButtons(initialQuestion: Binding<QuestModel>) -> some View {
//        Group {
//            VStack {
//                ForEach(0..<initialQuestion.wrappedValue.options.count, id: \.self) { index in
//                    Button(action: {
//                        // checkAnswerAndUpdateButtonState model üzerinde değişiklik yapacak
//                        mchoiceTestVM.checkAnswerAndUpdateButtonState(quest: initialQuestion.wrappedValue, selectedButton: index)
//                    }) {
//                        Text("\(initialQuestion.wrappedValue.options[index].optionText) (\(initialQuestion.wrappedValue.options[index].optionState))")
//                            .padding()
//                            .foregroundColor(.white)
////                            .background(backgroundForOption(at: index))
//                            .background(Color(.white.opacity(0.1)))
//                            .cornerRadius(100)
//                    }
//                    .padding(.all, 10)
//                }
//            }
//        }
//    }
    private func choiceButtons(initialQuestion: Binding<QuestModel>) -> some View {

           Group {
               
                   
                   VStack{
                       Button(action: {
                           mchoiceTestVM.checkAnswerAndUpdateButtonState(quest: initialQuestion.wrappedValue, selectedButton: 0)
                           if(initialQuestion.wrappedValue.word.translatedWords![0] == initialQuestion.wrappedValue.options[0].optionText){
                               buttonColor = .green
                           }else {
                               buttonColor = .red
                           }

                       }) {
                           Text(initialQuestion.wrappedValue.options[0].optionText + " (\(initialQuestion.wrappedValue.options[0].optionState))")
                               .padding()
                               .foregroundColor(.white)
                               .background(buttonColor.opacity(0.1))
                               .cornerRadius(100)
                       }
                       .padding(.all, 10)
                       
                       Button(action: {
                           mchoiceTestVM.checkAnswerAndUpdateButtonState(quest: initialQuestion.wrappedValue, selectedButton: 1)
                           if(initialQuestion.wrappedValue.word.translatedWords![0] == initialQuestion.wrappedValue.options[1].optionText){
                               buttonColor2 = .green
                           }else {
                               buttonColor2 = .red
                           }
                       }) {
                           Text(initialQuestion.wrappedValue.options[1].optionText + " (\(initialQuestion.wrappedValue.options[1].optionState))")
                               .padding()
                               .foregroundColor(.white)
                               .background(buttonColor2.opacity(0.1))
                               .cornerRadius(100)
                       }
                       .padding(.all, 10)
                       
                       Button(action: {
                           mchoiceTestVM.checkAnswerAndUpdateButtonState(quest: initialQuestion.wrappedValue, selectedButton: 2)
                           if(initialQuestion.wrappedValue.word.translatedWords![0] == initialQuestion.wrappedValue.options[2].optionText){
                               buttonColor3 = .green
                           }else {
                               buttonColor3 = .red
                           }
                       }) {
                           Text(initialQuestion.wrappedValue.options[2].optionText + " (\(initialQuestion.wrappedValue.options[2].optionState))")
                               .padding()
                               .foregroundColor(.white)
                               .background(buttonColor3.opacity(0.1))
                               .cornerRadius(100)
                       }
                       .padding(.all, 10)
                       
                       Button(action: {
                           mchoiceTestVM.checkAnswerAndUpdateButtonState(quest: initialQuestion.wrappedValue, selectedButton: 3)
                           if(initialQuestion.wrappedValue.word.translatedWords![0] == initialQuestion.wrappedValue.options[3].optionText){
                               buttonColor4 = .green
                           }else {
                               buttonColor4 = .red
                           }
                       }) {
                           Text(initialQuestion.wrappedValue.options[3].optionText + " (\(initialQuestion.wrappedValue.options[3].optionState))")
                               .padding()
                               .foregroundColor(.white)
                               .background(buttonColor4.opacity(0.1))
                               .cornerRadius(100)
                       }
                       .padding(.all, 10)
                   }
              
               
           }
        
       }
    
    
}

//#Preview {
//    MchoiceTestView()
//}

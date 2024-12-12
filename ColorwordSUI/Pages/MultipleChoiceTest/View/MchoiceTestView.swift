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
    @State private var buttonColorList: [Color] = [.white.opacity(0.3), .white.opacity(0.3), .white.opacity(0.3), .white.opacity(0.3)]
    
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
                                    
                                    choiceButtons(initialQuestion: .constant(onPageQuestion), onPageQuestion: onPageQuestion)
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

                            buttonColorList = [.white.opacity(0.3), .white.opacity(0.3), .white.opacity(0.3), .white.opacity(0.3)]
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

    //TODO: Şuan bu aşamada istediğime yakınım
    //Ancak saçma olan işler var yani bu amele mantığı bir metod ile düzeltmeliyim.
    // Aşağıdaki butonların rengini değiştirme işlemini daha düzgün viewmodelden gerekirse düzenlemeliyim.
    private func choiceButtons(initialQuestion: Binding<QuestModel>, onPageQuestion: QuestModel) -> some View {

           Group {
                   VStack{
                       Button(action: {
                           mchoiceTestVM.checkAnswerAndUpdateButtonState(quest: initialQuestion.wrappedValue, selectedButton: 0)
                           updateButtonColors(optionList: initialQuestion.wrappedValue.options)

                       }) {
                           Text(initialQuestion.wrappedValue.options[0].optionText + " (\(initialQuestion.wrappedValue.options[0].optionState))")
                               .padding()
                               .foregroundColor(.white)
                               .background(buttonColorList[0])
                               .cornerRadius(100)
                       }
                       .padding(.all, 10)
                       
                       Button(action: {
                           mchoiceTestVM.checkAnswerAndUpdateButtonState(quest: initialQuestion.wrappedValue, selectedButton: 1)
                           updateButtonColors(optionList: initialQuestion.wrappedValue.options)

                       }) {
                           Text(initialQuestion.wrappedValue.options[1].optionText + " (\(initialQuestion.wrappedValue.options[1].optionState))")
                               .padding()
                               .foregroundColor(.white)
                               .background(buttonColorList[1])
                               .cornerRadius(100)
                       }
                       .padding(.all, 10)
                       
                       Button(action: {
                           mchoiceTestVM.checkAnswerAndUpdateButtonState(quest: initialQuestion.wrappedValue, selectedButton: 2)
                           updateButtonColors(optionList: initialQuestion.wrappedValue.options)

                       }) {
                           Text(initialQuestion.wrappedValue.options[2].optionText + " (\(initialQuestion.wrappedValue.options[2].optionState))")
                               .padding()
                               .foregroundColor(.white)
                               .background(buttonColorList[2])
                               .cornerRadius(100)
                       }
                       .padding(.all, 10)
                       
                       Button(action: {
                           mchoiceTestVM.checkAnswerAndUpdateButtonState(quest: initialQuestion.wrappedValue, selectedButton: 3)
                           updateButtonColors(optionList: initialQuestion.wrappedValue.options)
                       }) {
                           Text(initialQuestion.wrappedValue.options[3].optionText + " (\(initialQuestion.wrappedValue.options[3].optionState))")
                               .padding()
                               .foregroundColor(.white)
                               .background(buttonColorList[3])
                               .cornerRadius(100)
                       }
                       .padding(.all, 10)
                   }
           }
       }
    
    func updateButtonColors(optionList: [OptionModel]) {
        
        buttonColorList = optionList.map { option in
            if option.optionState == .correct {
                return .green
            } else if option.optionState == .wrong {
                return .red
            } else {
                return .white.opacity(0.3)
            }
        }
    }
}

//#Preview {
//    MchoiceTestView()
//}

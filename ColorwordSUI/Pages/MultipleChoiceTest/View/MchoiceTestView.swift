//
//  MchoiceTestView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 22.11.2024.
//

import SwiftUI

//TODO: sayfa ile işim bittiğinde taşınabilecek her değişkeni vm ye taşı. state ve binding durumları sorun çıkartmayacaksa
struct MchoiceTestView: View {
    @StateObject var mchoiceTestVM = MchoiceTestViewModel()
    @State private var selectedTabIndex = 0
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var buttonColorList: [Color] = [.white.opacity(0.2), .white.opacity(0.2), .white.opacity(0.2), .white.opacity(0.2)]
    
    @State private var opacity: Double = 1.0
    
    @State private var isButtonsEnabled: Bool = true
    
    @State private var isAnsweredList: [Bool] = []

    
    //Auto slide işlemi için yine alttaki timera ihtiyaç olabilir
//    @State private var timeRemaining = 10
//    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    
    //TODO: Sayfaya genel bir kontrol eklenecek. kişi 5ten az kelime eklediyse buraya gelmemeli, alert gösterilmeli.
    var body: some View {
        ZStack(alignment: .center) {
            VStack {
                //TODO: Loading göstergesi
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
                                    
                                    if (onPageQuestion.options.isEmpty != true ) {
                                        choiceButtons(initialQuestion: .constant(onPageQuestion))
                                    }
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
                            
                            if isAnsweredList[newIndex] {
                                isButtonsEnabled = false
                            } else {
                                isButtonsEnabled = true
                                buttonColorList = [.white.opacity(0.2), .white.opacity(0.2), .white.opacity(0.2), .white.opacity(0.2)]
                            }
                        }
                    }
                }
            }
            .background(Color(hex: mchoiceTestVM.wordBackgroundColor))
            .edgesIgnoringSafeArea(.all)
            .task {
                mchoiceTestVM.questList = await mchoiceTestVM.createThreeUniqueOption()
                isAnsweredList = Array(repeating: false, count: mchoiceTestVM.questList.count)

            }
        }
    }

    private func choiceButtons(initialQuestion: Binding<QuestModel>) -> some View {

           Group {
               
               VStack {
                   OptionButtonWidget(
                                   action: {
                                       mchoiceTestVM.checkAnswerAndUpdateButtonState(
                                           quest: initialQuestion.wrappedValue,
                                           selectedButton: 0
                                       )
                                       
                                       mchoiceTestVM.updateButtonColors(
                                           optionList: initialQuestion.wrappedValue.options,
                                           buttonColorList: &buttonColorList
                                       )
                                       isButtonsEnabled = false
                                       isAnsweredList[selectedTabIndex] = true
                                       selectedTabIndex = selectedTabIndex+1
                                   },
                                   initialQuestion: initialQuestion,
                                   backgroundColor: $buttonColorList[0],
                                   buttonIndex: 0
                                ).disabled(isAnsweredList[selectedTabIndex])
                               
                               OptionButtonWidget(
                                   action:  {
                                       mchoiceTestVM.checkAnswerAndUpdateButtonState(
                                           quest: initialQuestion.wrappedValue,
                                           selectedButton: 1
                                       )
                                       mchoiceTestVM.updateButtonColors(
                                           optionList: initialQuestion.wrappedValue.options,
                                           buttonColorList: &buttonColorList
                                       )
                                       isButtonsEnabled = false
                                       isAnsweredList[selectedTabIndex] = true
                                       selectedTabIndex = selectedTabIndex+1

                                   },
                                   initialQuestion: initialQuestion,
                                   backgroundColor: $buttonColorList[1],
                                   buttonIndex: 1
                               ).disabled(isAnsweredList[selectedTabIndex])

                               OptionButtonWidget(
                                   action: {
                                       mchoiceTestVM.checkAnswerAndUpdateButtonState(
                                           quest: initialQuestion.wrappedValue,
                                           selectedButton: 2
                                       )
                                       mchoiceTestVM.updateButtonColors(
                                           optionList: initialQuestion.wrappedValue.options,
                                           buttonColorList: &buttonColorList
                                       )
                                       isButtonsEnabled = false
                                       isAnsweredList[selectedTabIndex] = true
                                       selectedTabIndex = selectedTabIndex+1

                                   },
                                   initialQuestion: initialQuestion,
                                   backgroundColor: $buttonColorList[2],
                                   buttonIndex: 2
                               ).disabled(isAnsweredList[selectedTabIndex])

                               OptionButtonWidget(
                                   action: {
                                       mchoiceTestVM.checkAnswerAndUpdateButtonState(
                                           quest: initialQuestion.wrappedValue,
                                           selectedButton: 3
                                       )
                                       mchoiceTestVM.updateButtonColors(
                                           optionList: initialQuestion.wrappedValue.options,
                                           buttonColorList: &buttonColorList
                                       )
                                       isButtonsEnabled = false
                                       isAnsweredList[selectedTabIndex] = true
                                       selectedTabIndex = selectedTabIndex+1

                                   },
                                   initialQuestion: initialQuestion,
                                   backgroundColor: $buttonColorList[3],
                                   buttonIndex: 3
                               ).disabled(isAnsweredList[selectedTabIndex])

                   
               }
           }
       }
    
}

//#Preview {
//    MchoiceTestView()
//}

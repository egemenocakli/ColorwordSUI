//
//  MchoiceTestView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 22.11.2024.
//

import SwiftUI

//TODO: sayfa ile işim bittiğinde taşınabilecek her değişkeni vm ye taşı. state ve binding durumları sorun çıkartmayacaksa
//Aynı şekilde iconlar ve buton renkleri de taşınacak

struct MchoiceTestView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject var mchoiceTestVM = MchoiceTestViewModel()
    @State private var selectedTabIndex = 0
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var buttonColorList: [Color] = Array(repeating: Constants.ColorConstants.optionButtonBackgroundColor, count: 4)
    @State private var opacity: Double = 1.0
    @State private var isButtonsEnabled: Bool = true
    @State private var isAnsweredList: [Bool] = []
    @State private var showSettings = false
    @State private var animationActive = true
    @State private var animamationSpeedToggle: AnimationToggleState = .normal
    @State private var showToast: Bool = false    


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
                }
                else {
                    VStack {
                        TabView(selection: $selectedTabIndex) {
                            ForEach(Array(mchoiceTestVM.questList.enumerated()), id: \.element.word.wordId) { index, onPageQuestion in
                                VStack {
                                    if(mchoiceTestVM.isCorrectCheckForIcon != nil && onPageQuestion.options[0].optionState != .none) {
                                        AnswerIcon(isCorrect: mchoiceTestVM.isCorrectCheckForIcon!)
                                    }
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
                                    if ($selectedTabIndex.wrappedValue == mchoiceTestVM.questList.count-1 && isAnsweredList[index] == true ) {
                                        showResultToastMessage(onPageQuestNo: index, totalQuestions: mchoiceTestVM.questList.count)
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
                                changeButtonStateAndColor()
                            }
                            mchoiceTestVM.isAnswerCorrect = false
                            emptyFinder(oldIndex: oldIndex)
                            mchoiceTestVM.isCorrectCheckForIcon = nil
                        }
                    }
                
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Image(systemName: Constants.IconTextConstants.settingsButton)
                            .font(.system(size: Constants.FontSizeConstants.x2Large))
                            .foregroundColor(Constants.ColorConstants.grayButtonColor)
                    }
                }
            
                    
//TODO: Ayrı bir method olarak yazılcak
                }.sheet(isPresented: $showSettings) {
                    VStack {
                        Text("test_settings")
                            .font(.headline)
                            .padding()

                        Toggle("auto_slide_toggle", isOn: $animationActive)
                            .padding()
           
                        Toggle("auto_slide_speed", isOn: Binding(
                                        get: { animamationSpeedToggle.isFast },
                                        set: { newValue in
                                            animamationSpeedToggle = AnimationToggleState(isFast: newValue)
                                        }
                                    ))
                                    .padding()

                        Button("close") {
                            showSettings = false
                        }
                        .padding()
                        .foregroundColor(.red)
                    }
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .background(Color(hex: mchoiceTestVM.wordBackgroundColor))
            .edgesIgnoringSafeArea(.all)
            .task {
                mchoiceTestVM.questList = await mchoiceTestVM.createQuestList()
                isAnsweredList = Array(repeating: false, count: mchoiceTestVM.questList.count)

            }
            
        }.environment(\.locale, .init(identifier: languageManager.currentLanguage))

        
    }
    //TODO: Test edilecek ilk boş orta boş ve son soru boş bırakılacak
    ///**Finds the question that was skipped**
    fileprivate func emptyFinder(oldIndex: Int) {
        //ilk sayfa kontrolü yapılacak
        
        if(isAnsweredList[selectedTabIndex-1] == false) {
            mchoiceTestVM.answerList?[selectedTabIndex-1] = .empty
        }
    }

    ///**User test result showing with ToastMessage**
    fileprivate func showResultToastMessage(onPageQuestNo: Int, totalQuestions: Int) -> some View{
        let result = mchoiceTestVM.checkAnswers()
        return ZStack {
            ToastView(message: result)
                .transition(.slide)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.showToast = false
                    }
                }
            
        }
    }
    
    ///**User when pick one choice if does not slide the page this method will be autoslide.**
    fileprivate func asyncTimerCompareValues(timerSecond: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(timerSecond)) {
            let result = mchoiceTestVM.compareValues(with: selectedTabIndex)
            if result != -1 {
                selectedTabIndex = result
            }
        }
    }
    ///**Change the score of the word by taking the true or false status from the button selected by the user.**
    fileprivate func getUserAnswer(initialQuestion: Binding<QuestModel>, selectedOptionNo: Int) {
        let screenWord: Word = initialQuestion.wrappedValue.word
        
        initialQuestion.wrappedValue.options[selectedOptionNo].optionText == initialQuestion.wrappedValue.word.translatedWords![0] ? mchoiceTestVM.isAnswerCorrect = true : nil
        Task {
            await mchoiceTestVM.getUserAnswer(word: screenWord,pageIndex: selectedTabIndex)
         }
    }
    ///**The question option buttons**
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
                                       if(animationActive == true) {
                                           mchoiceTestVM.startProcess(with: selectedTabIndex,timerSeconds: $animamationSpeedToggle.wrappedValue.rawValue)
                                           asyncTimerCompareValues(timerSecond: $animamationSpeedToggle.wrappedValue.rawValue)
                                       }
                                       
                                       
                                       getUserAnswer(initialQuestion: initialQuestion,selectedOptionNo: 0)
                                   },
                                   initialQuestion: initialQuestion,
                                   backgroundColor: $buttonColorList[0],
                                   buttonIndex: 0,
                                   animationDuration: animamationSpeedToggle.rawValue
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
                                       if(animationActive == true) {
                                           mchoiceTestVM.startProcess(with: selectedTabIndex,timerSeconds: $animamationSpeedToggle.wrappedValue.rawValue)
                                           asyncTimerCompareValues(timerSecond: $animamationSpeedToggle.wrappedValue.rawValue)
                                       }
                                       getUserAnswer(initialQuestion: initialQuestion,selectedOptionNo: 1)
                                   },
                                   initialQuestion: initialQuestion,
                                   backgroundColor: $buttonColorList[1],
                                   buttonIndex: 1,
                                   animationDuration: animamationSpeedToggle.rawValue
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
                                       if(animationActive == true) {
                                           mchoiceTestVM.startProcess(with: selectedTabIndex,timerSeconds: $animamationSpeedToggle.wrappedValue.rawValue)
                                           asyncTimerCompareValues(timerSecond: $animamationSpeedToggle.wrappedValue.rawValue)
                                       }
                                       getUserAnswer(initialQuestion: initialQuestion,selectedOptionNo: 2)

                                   },
                                   initialQuestion: initialQuestion,
                                   backgroundColor: $buttonColorList[2],
                                   buttonIndex: 2,
                                   animationDuration: animamationSpeedToggle.rawValue
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
                                       if(animationActive == true) {
                                           mchoiceTestVM.startProcess(with: selectedTabIndex,timerSeconds: $animamationSpeedToggle.wrappedValue.rawValue)
                                           asyncTimerCompareValues(timerSecond: $animamationSpeedToggle.wrappedValue.rawValue)
                                       }
                                       getUserAnswer(initialQuestion: initialQuestion,selectedOptionNo: 3)

                                   },
                                   initialQuestion: initialQuestion,
                                   backgroundColor: $buttonColorList[3],
                                   buttonIndex: 3,
                                   animationDuration: animamationSpeedToggle.rawValue
                               ).disabled(isAnsweredList[selectedTabIndex])

                   
               }
           }
       }
    fileprivate func changeButtonStateAndColor() {
        isButtonsEnabled = true
        buttonColorList = Array(repeating: Constants.ColorConstants.optionButtonBackgroundColor, count: 4)
    }
    
    ///**The method where we show the results to the user at the end of the test.**
    struct ToastView: View {
        var message: String
        var body: some View {
            Text(message)
                .padding()
                .background(Constants.ColorConstants.toastMessageBackgroundColor)
                .foregroundColor(Constants.ColorConstants.whiteColor)
                .cornerRadius(Constants.SizeRadiusConstants.xSmall)
                .padding(.top, Constants.PaddingSizeConstants.lSize)
        }
    }
    ///**When the user makes a selection, a true/false icon is displayed on the screen.**
    struct AnswerIcon: View {
        @State private var isVisible = true
        
        var style: AnswerIconStyle

        init(isCorrect: Bool) {
            self.style = AnswerIconStyle(isCorrect: isCorrect)
        }
        
        var body: some View {
            
            Image(systemName: style.systemImageName).font(Font.system(size: Constants.FontSizeConstants.hugeSize)).foregroundStyle(.white)
                .padding()
                .opacity(isVisible ? 1 : 0)
                .animation(.spring(response: Constants.TimerTypeConstants.standardSpringAnimation, dampingFraction: Constants.TimerTypeConstants.standardSpringAnimation), value: isVisible)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.TimerTypeConstants.shortTimer) {
                        isVisible = false
                    }
                }
        }
    }
}




//#Preview {
//    MchoiceTestView()
//}


//TODO: Toplam kelime sayısı ve gösterilen sayfadaki kelimenin sırası
//TODO: Appbar yazı/buton renkleri aynı olsun

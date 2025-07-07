//
//  MchoiceTestView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 22.11.2024.
//

import SwiftUI

//TODO: sayfa ile işim bittiğinde taşınabilecek her değişkeni vm ye taşı. state ve binding durumları sorun çıkartmayacaksa

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
    @State private var navigateToNextScreen = false


    //TODO: Sayfaya genel bir kontrol eklenecek. kişi 5ten az kelime eklediyse buraya gelmemeli, alert gösterilmeli.

    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
                Color(hex: mchoiceTestVM.wordBackgroundColor)
                    .animation(.easeInOut(duration: Constants.TimerTypeConstants.standardSpringAnimation), value: mchoiceTestVM.wordBackgroundColor)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if (mchoiceTestVM.questList.isEmpty && mchoiceTestVM.questList.count > 5) {
                        ProgressView("loading")
                            .progressViewStyle(CircularProgressViewStyle(tint: Constants.ColorConstants.whiteColor))
                    }
                    else {
                        VStack {
                            TabView(selection: $selectedTabIndex) {
                                ForEach(Array(mchoiceTestVM.questList.enumerated()), id: \.element.word.wordId) { index, onPageQuestion in
                                    VStack {
                                        if(mchoiceTestVM.isCorrectCheckForIcon != nil && onPageQuestion.options[0].optionState != .none) {
                                            AnswerIcon(isCorrect: mchoiceTestVM.isCorrectCheckForIcon!)
                                        }
                                        OnPageWordTextWidget(onPageQuestion: onPageQuestion)
                                        
                                        if (onPageQuestion.options.isEmpty != true ) {
                                            choiceButtons(initialQuestion: .constant(onPageQuestion))
                                        }
                                        
                                        if ($selectedTabIndex.wrappedValue == mchoiceTestVM.questList.count-1 && isAnsweredList[index] == true ) {
                                            showResultToastMessage()
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
                    settingsSheetWidget()
                }
                .background(
                    Color(Color(hex: mchoiceTestVM.wordBackgroundColor)!)
                        .animation(.easeInOut(duration: Constants.TimerTypeConstants.standardSpringAnimation), value: Color(hex: mchoiceTestVM.wordBackgroundColor))
                )
                .edgesIgnoringSafeArea(.all)
                .task {
                    mchoiceTestVM.questList = await mchoiceTestVM.createQuestList()
                    isAnsweredList = Array(repeating: false, count: mchoiceTestVM.questList.count)
                    
                    if let firstWord = mchoiceTestVM.wordList.first {
                        mchoiceTestVM.getWordColorForBackground(word: firstWord, themeManager: themeManager)
                    }
                }
                
            }
            .environment(\.locale, .init(identifier: languageManager.currentLanguage))
            .navigationDestination(isPresented: $navigateToNextScreen) {
                WordListView()
            }
            
        }
    }

    ///**Finds the question that was skipped**
    fileprivate func emptyFinder(oldIndex: Int) {
        //ilk sayfa kontrolü yapılacak
        guard selectedTabIndex > 0, selectedTabIndex - 1 < isAnsweredList.count else {
            return
        }

        if !isAnsweredList[selectedTabIndex - 1] {
            mchoiceTestVM.answerList?[selectedTabIndex - 1] = .empty
        }
    }

    ///**User test result showing with ToastMessage**
    fileprivate func showResultToastMessage() -> some View{

        let result = mchoiceTestVM.checkAnswers()
        return ZStack {
            
            ToastWidget(message: result)
                .transition(.slide)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.showToast = false
                        self.navigateToNextScreen = true 

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
    
    fileprivate func settingsSheetWidget() -> some View {
        return VStack {
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
        .presentationDetents([.fraction(0.35)])
        .presentationCornerRadius(Constants.SizeRadiusConstants.large)
        .presentationDragIndicator(.visible)
    }
    
    
    fileprivate func changeButtonStateAndColor() {
        isButtonsEnabled = true
        buttonColorList = Array(repeating: Constants.ColorConstants.optionButtonBackgroundColor, count: 4)
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




#Preview {
    MchoiceTestView()
}


//TODO: Toplam kelime sayısı ve gösterilen sayfadaki kelimenin sırası

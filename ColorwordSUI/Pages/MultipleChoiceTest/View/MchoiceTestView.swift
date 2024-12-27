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
    @State private var buttonColorList: [Color] = [.black.opacity(0.12), .black.opacity(0.12), .black.opacity(0.12), .black.opacity(0.12)]
    @State private var opacity: Double = 1.0
    @State private var isButtonsEnabled: Bool = true
    @State private var isAnsweredList: [Bool] = []

    @State private var showSettings = false
    @State private var animationActive = true
    @State private var animamationSpeedToggle: AnimationToggleState = .normal
    
    enum AnimationToggleState: Int {
        case fast = 1
        case normal = 3
        
        var isFast: Bool {
            self == .fast
        }
        
        init(isFast: Bool) {
            self = isFast ? .fast : .normal
        }
        
        var value: Int {
            return self.rawValue
        }
    }


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
                                buttonColorList = [.black.opacity(0.12), .black.opacity(0.12), .black.opacity(0.12), .black.opacity(0.12)]
                            }
                            mchoiceTestVM.userAnswer = false
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")  // SF Symbol: Ayarlar simgesi
                            .font(.title2)  // Simge boyutu
                            .foregroundColor(.white)
                    }
                }
            
                    

                }.sheet(isPresented: $showSettings) {
                    // Sheet içeriği
                    VStack {
                        Text("Ayarlar Menüsü")
                            .font(.headline)
                            .padding()

                        Toggle("Otomatik Kaydırma (Açık/Kapalı)", isOn: $animationActive)
                            .padding()
           
                        Toggle("Otomatik Kaydırma Hızı (Normal/Hızlı)", isOn: Binding(
                                        get: { animamationSpeedToggle.isFast },  // Bool olarak enum durumu
                                        set: { newValue in
                                            animamationSpeedToggle = AnimationToggleState(isFast: newValue)
                                        }
                                    ))
                                    .padding()

                        Button("Kapat") {
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
        }
    }

    //User when pick one choice if does not slide the page this method will be autoslide.
    fileprivate func asyncTimerCompareValues(timerSecond: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(timerSecond)) {
            let result = mchoiceTestVM.compareValues(with: selectedTabIndex)
            if result != -1 {
                selectedTabIndex = result
            }
        }
    }
    
    fileprivate func getUserAnswer(initialQuestion: Binding<QuestModel>, selectedOptionNo: Int) {
        let screenWord: Word = initialQuestion.wrappedValue.word
        
        initialQuestion.wrappedValue.options[selectedOptionNo].optionText == initialQuestion.wrappedValue.word.translatedWords![0] ? mchoiceTestVM.userAnswer = true : nil
        Task {
            await mchoiceTestVM.getUserAnswer(word: screenWord)
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
    
}




//#Preview {
//    MchoiceTestView()
//}



/*
 Yapılacaklar:
 
    bottom sheet e eklenecek özellikler belirlenecek (Animasyon hızı: normal/hızlı)
    manuel kaydırma: autoslide özelliğini kapatır kullanıcı kaydırır.
 
    geri tuşunu ben koymadım otomatik geliyor ve dil kendi kendine değişiyor yapabilrsem rengini ikisinin de beyaz veya gri tonunda yapmalıyım.
 */

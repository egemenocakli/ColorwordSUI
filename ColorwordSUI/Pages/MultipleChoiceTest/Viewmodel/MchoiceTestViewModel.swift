//
//  MchoiceTestViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 22.11.2024.
//

import Foundation
import SwiftUI

class MchoiceTestViewModel: ObservableObject {
    @Published var wordBackgroundColor: String = "#00FFFFFF"
    @Published var questList: [QuestModel] = []
    
    var wordList : [Word] = []
    let mChoiceTestService = MchoiceTestService()
    
    @State var onPageQuestion: QuestModel?
//    @State var buttonColorList: [Color] = [.white.opacity(0.2), .white.opacity(0.2), .white.opacity(0.2), .white.opacity(0.2)]
    
    
//    @Published var isPressed1: Bool = false
//    @Published var isPressed2: Bool = false
//    @Published var isPressed3: Bool = false
//    @Published var isPressed4: Bool = false

    
    func getWordList() async  -> [Word]? {
        
        
        do {
            wordList = try await mChoiceTestService.getWordList()

        }catch {
            print(error)
        }
        if  wordList.isEmpty != true {
            return wordList
        }else {
            return nil
        }
    }
    
    //optionlist
    func createOptionList() async -> Set<String>{
        
        var optionList: Set<String> = []
        
        self.wordList =  await getWordList() ?? []
      
        if wordList.isEmpty != true {
            wordList.forEach({ word in
                  optionList.insert(word.translatedWords?[0] ?? "")
                  print(word.translatedWords?[0] ?? "")
              })
          }else {
              optionList = []
          }
        
        return optionList
    }
    

    func createThreeUniqueOption() async -> [QuestModel] {
        
        var questList: [QuestModel] = []
        let createdOptionList = await createOptionList()
        print(createdOptionList.count)
        
        
        wordList.forEach({ word in
            var randomOptions: [String] = []
            randomOptions.append(word.translatedWords?[0] ?? "")
            
            let filteredOptionList = createdOptionList.filter { $0 != word.translatedWords?[0] }
            randomOptions.append(contentsOf: filteredOptionList.shuffled().prefix(3))
            
            let optionStates: [OptionState] = [.correct, .none, .none, .none]

            let optionModelList = zip(randomOptions, optionStates).map { optionText, optionState in
                OptionModel(optionText: optionText, optionState: optionState, buttonColor: .white.opacity(0.3))
            }
            /*
             var optionModelList: [OptionModel] = []
                         optionModelList.append(OptionModel(optionText: randomOptions[0], optionState: OptionState.correct))
                         optionModelList.append(OptionModel(optionText: randomOptions[1], optionState: OptionState.none))
                         optionModelList.append(OptionModel(optionText: randomOptions[2], optionState: OptionState.none))
                         optionModelList.append(OptionModel(optionText: randomOptions[3], optionState: OptionState.none))
             */
            questList.append(QuestModel(word: word, options: optionModelList.shuffled()))
            
        })
        
        

        return questList
    }
    
    //parametreler: kelime(translated[0]), quest.options[], seçilen buton
    //değişecekler: buttonState,buttonBackground, butonlar disabled olacak
   
        
        func checkAnswerAndUpdateButtonState(quest: QuestModel?, selectedButton: Int?) {

            
            guard let quest = quest, let _ = selectedButton else {
                print("Hata: Quest veya selectedButton boş")
                return
            }
            
            guard let correctAnswer = quest.word.translatedWords?.first else {
                print("Hata: translatedWords boş")
                return
            }
                 
                for option in quest.options {
                    if option.optionText != correctAnswer {
                        option.optionState = .wrong
                    } else {
                        option.optionState = .correct
                    }
                }
        }

    
    func updateButtonColors(optionList: [OptionModel], buttonColorList: inout [Color]) {
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
    
    
    
    func getWordColorForBackground(word: Word, themeManager: ThemeManager){
        
        if (themeManager.selectedTheme != Constants.AppTheme.dark_mode.rawValue) {
            let backgroudColor = word.color?.toHex() ?? "#000000"
            wordBackgroundColor = backgroudColor
        }
        else {
            wordBackgroundColor = "#000000"
        }
    }
    
    
}

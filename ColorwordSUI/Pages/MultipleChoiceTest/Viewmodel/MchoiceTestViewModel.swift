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
    var storedValue: Int = 0
    var timerIsFinished: Bool = false
    var userAnswer: Bool = false

    ///Returns the user's word list. #1 QuestAndOption: Order of Operations
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
    
    
    ///Create all quest and options list. #2 QuestAndOption: Order of Operations
    func createQuestList() async -> [QuestModel] {
        
        var questList: [QuestModel] = []
        let createdOptionList = await createOptionList()
        
        
        wordList.forEach({ word in
            var randomOptions: [String] = []
            randomOptions.append(word.translatedWords?[0] ?? "")
            
            let filteredOptionList = createdOptionList.filter { $0 != word.translatedWords?[0] }
            randomOptions.append(contentsOf: filteredOptionList.shuffled().prefix(3))
            
            let optionStates: [OptionState] = [.correct, .none, .none, .none]

            let optionModelList = zip(randomOptions, optionStates).map { optionText, optionState in
                OptionModel(optionText: optionText, optionState: optionState, buttonColor: .white.opacity(0.3))
            }

            questList.append(QuestModel(word: word, options: optionModelList.shuffled()))
            
        })

        return questList
    }
    
    ///Create options from all wordlist. #3 QuestAndOption: Order of Operations
    func createOptionList() async -> Set<String>{
        
        var optionList: Set<String> = []
        
        self.wordList =  await getWordList() ?? []
      
        if wordList.isEmpty != true {
            wordList.forEach({ word in
                  optionList.insert(word.translatedWords?[0] ?? "")
              })
          }else {
              optionList = []
          }
        
            return optionList
    }
    
    ///Check all options and changing optionState's. #4 QuestAndOption: Order of Operations
    func checkAnswerAndUpdateButtonState(quest: QuestModel?, selectedButton: Int?) {

            
        guard let quest = quest, let _ = selectedButton else {
            print("Hata: Quest veya selectedButton boş. getUserAnswer")
            return
        }
            
        guard let correctAnswer = quest.word.translatedWords?.first else {
            print("Hata: translatedWords boş. getUserAnswer")
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

    ///Check optionState's and change them color. #5 QuestAndOption: Order of Operations
    func updateButtonColors(optionList: [OptionModel], buttonColorList: inout [Color]) {
        buttonColorList = optionList.map { option in
            if option.optionState == .correct {
                return Constants.ColorConstants.correctButtonColor
            } else if option.optionState == .wrong {
                return Constants.ColorConstants.wrongButtonColor
            } else {
                return Constants.ColorConstants.borderColor
            }
        }
    }
    
    ///Update word score after user selection. #6 QuestAndOption: Order of Operations
    func getUserAnswer(word: Word) async {
        var updatedWord = word
        
        if (userAnswer == true) {
            updatedWord.score = (updatedWord.score ?? 0) + 2
            
            do{
                try await mChoiceTestService.increaseWordScore(word: updatedWord, points: 2)
            }catch {
                print("getUserAnswer error")
            }
        }else {
            do{
                if (updatedWord.score! >= 2) {
                    updatedWord.score = (updatedWord.score ?? 0) - 2
                }else {
                    updatedWord.score = 0
                }
                
                try await mChoiceTestService.decreaseWordScore(word: updatedWord, points: 2)
            }catch {
                print("getUserAnswer error")
            }
        }
    }
    
    ///Get word color then change background Color.
    func getWordColorForBackground(word: Word, themeManager: ThemeManager){
        
        if (themeManager.selectedTheme != Constants.AppTheme.dark_mode.rawValue) {
            let backgroudColor = word.color?.toHex() ?? Constants.ColorConstants.blackHex
            wordBackgroundColor = backgroudColor
        }
        else {
            wordBackgroundColor = Constants.ColorConstants.blackHex
        }
    }
    
    ///User slide control methods. #1 PageSlide: Order of Operations
    func startProcess(with initialValue: Int,timerSeconds: Int) {
        storedValue = initialValue
        timerIsFinished = false
        Timer.scheduledTimer(withTimeInterval: TimeInterval(timerSeconds), repeats: false) { _ in
            self.timerIsFinished = true
        }
    }
    
    ///Check the number of page when after user pick option. #2 PageSlide: Order of Operations
    func compareValues(with newValue: Int) -> Int {
        var newGetterValue = newValue

        
        if storedValue == newValue {
            storedValue = newGetterValue
            if (questList.count-1 != storedValue){
                newGetterValue = newGetterValue + 1
            }
            
            return newGetterValue
        } else {
            return newValue
        }
    }
}



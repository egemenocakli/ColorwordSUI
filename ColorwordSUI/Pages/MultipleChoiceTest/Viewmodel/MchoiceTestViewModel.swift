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

    
    var storedValue: Int = 0
    var timerIsFinished: Bool = false


    
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

            questList.append(QuestModel(word: word, options: optionModelList.shuffled()))
            
        })
        
        

        return questList
    }
    
        
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
    
    
    // 1. İlk metod: Parametre alır, değeri saklar ve timer başlatır
    func startProcess(with initialValue: Int) {
        storedValue = initialValue
        print("\(storedValue)" + "içeriği doldu")
        timerIsFinished = false // Timer'ın durumu resetlenir
        print("Initial value stored: \(storedValue)")
        
        // 2 saniyelik bir timer başlatılır
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            self.timerIsFinished = true
            print("Timer finished, ready for comparison.")
        }
    }
    
    
    //Burada ilk sayfada sorunsuz işliyor ikincisinde işlemiyor
    
    // 2. İkinci metod: Yeni bir değer alır ve saklanan değerle karşılaştırır
    func compareValues(with newValue: Int) -> Int {
        var newGetterValue = newValue
//        guard timerIsFinished else {
//            print("Timer is not finished yet. Please wait.")
//            return -1 // Timer bitmeden çağırılırsa -1 döndürülür
//        }
        
        if storedValue == newValue {
            print("Values match!")
            storedValue = newGetterValue
            if (questList.count-1 != storedValue){
                newGetterValue = newGetterValue + 1
            }
            
            return newGetterValue
        } else {
            
            print("Values do not match!")
            print(storedValue)
            print(newValue)
            return newValue
        }
    }

}


//TODO: doğru/yanlış şık tespiti ile increase metodu sonra decrase

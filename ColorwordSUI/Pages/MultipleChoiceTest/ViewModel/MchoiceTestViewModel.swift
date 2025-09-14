//
//  MchoiceTestViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 22.11.2024.
//

import Foundation
import SwiftUI

//Service methods:
//      -> getWordList
//      -> getUserAnswer
//      -> increaseDailyAndTotalScore

@MainActor
class MchoiceTestViewModel: ObservableObject {
    
    @Published var wordBackgroundColor: String = Constants.ColorConstants.blackHex
    @Published var questList: [QuestModel] = []
    var wordList : [Word] = []
    let mChoiceTestService = MchoiceTestService()
    var storedValue: Int = 0
    var timerIsFinished: Bool = false
    var isAnswerCorrect: Bool = false
    var selectedWordListName: String = ""

    enum AnswerState: String {
        case correct = "true"
        case wrong = "false"
        case empty = "empty"
    }
        
    var answerList: [AnswerState]? = nil
    @Published var isCorrectCheckForIcon: Bool? = nil
    
    
    func getSelectedWordListName(takenSelectedListName: String) {
        selectedWordListName = takenSelectedListName
    }
    
    ///Returns the user's word list. #1 QuestAndOption: Order of Operations
    func getWordList(selectedWordList: String) async  -> [Word]? {
        
        do {
            wordList = try await mChoiceTestService.getWordList(selectedWordList: selectedWordList)

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
    func createQuestList(selectedWordList: String) async -> [QuestModel] {
        
        var questList: [QuestModel] = []
        let createdOptionList = await createOptionList(selectedWordList: selectedWordList)
        
        
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
    func createOptionList(selectedWordList: String) async -> Set<String>{
        
        var optionList: Set<String> = []
        
        self.wordList =  await getWordList(selectedWordList: selectedWordList) ?? []
      
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
    ///Answer counter
    func getUserAnswer(word: Word, pageIndex: Int) async {
        var updatedWord = word
        
        guard UserSessionManager.shared.userInfoModel != nil else {
            print("userInfoModel bulunamadı")
            return
        }
        
        if answerList == nil {
            DispatchQueue.main.async {
                self.answerList = Array(repeating: .empty, count: self.wordList.count)
            }
        }
        
        if (isAnswerCorrect == true) {
            updatedWord.score = (updatedWord.score ?? 0) + 5
            DispatchQueue.main.async {
                self.isCorrectCheckForIcon = true
                self.answerList?[pageIndex] = .correct
                
                print(pageIndex)
            }
            
            do{
                try await mChoiceTestService.increaseWordScore(selectedWordList: selectedWordListName, word: updatedWord, points: 5)
                //Burası değişecek 100 puan kastıkca güncellemek lazım ama nasıl?
                try await mChoiceTestService.updateLeaderboardScore(by: 5, userInfo: UserSessionManager.shared.userInfoModel)
                increaseDailyAndTotalScore()
            }catch {
                print("getUserAnswer error")
            }
        }else if (isAnswerCorrect == false ){
            do{
                if (updatedWord.score! >= 2) {
                    updatedWord.score = (updatedWord.score ?? 0) - 2
                }else {
                    updatedWord.score = 0
                }
                DispatchQueue.main.async {
                    self.isCorrectCheckForIcon = false
                    self.answerList![pageIndex] = .wrong
                }
                try await mChoiceTestService.decreaseWordScore(selectedWordList: selectedWordListName, word: updatedWord, points: 2)
            }catch {
                print("getUserAnswer error")
            }
            
        }
    }
    
    func increaseDailyAndTotalScore() {
        
        guard UserSessionManager.shared.userInfoModel != nil else {
            print("userInfoModel bulunamadı")
            return
        }
        
        
        if var userInfoModel = UserSessionManager.shared.userInfoModel {
            userInfoModel.dailyScore = UserSessionManager.shared.userInfoModel!.dailyScore + Constants.ScoreConstants.multipleChoiceQuestionScore
            userInfoModel.totalScore = UserSessionManager.shared.userInfoModel!.totalScore + Constants.ScoreConstants.multipleChoiceQuestionScore
            
            UserSessionManager.shared.updateUserInfoModel(with: userInfoModel)
            
            mChoiceTestService.increaseUserInfoPoints(for: userInfoModel) { result in
                if result {
                    print("Kullanıcı puanları başarılı şekilde güncellendi.")
                }else {
                    print("Puan güncelleme işlemi başarısız oldu.")
                }
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
        Timer.scheduledTimer(withTimeInterval: TimeInterval(timerSeconds), repeats: false) { [weak self] _ in
            self?.timerIsFinished = true
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
    
    
    //TODO: Yine bir sorun var gibi tam olarak doğru vermiyor. tekrar kontrol edilecek.
    func checkAnswers() -> String {
        var trueAnswerCount = 0
        var falseAnswerCount = 0
        var emptyAnswerCount = 0
        
        if let answerList = answerList, !answerList.isEmpty {
            answerList.forEach { answer in
                switch answer {
                case .correct:
                    trueAnswerCount += 1
                case .wrong:
                    falseAnswerCount += 1
                case .empty:
                    emptyAnswerCount += 1
                }
            }
        }
//        print(emptyAnswerCounter)
        
        
        return """
        Doğru cevaplar: \(trueAnswerCount)
        Yanlış cevaplar: \(falseAnswerCount)
        Boş cevaplar: \(emptyAnswerCount)
        """
    }

        
}



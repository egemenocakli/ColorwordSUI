//
//  MchoiceTestViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 22.11.2024.
//

import Foundation

class MchoiceTestViewModel: ObservableObject {
    @Published var questList: [QuestModel] = []
    
    var wordList : [Word]? = []
    
   let mChoiceTestService = MchoiceTestService()

    //İlk etap
    func getWordList() async  -> [Word]? {
        
        
        do {
            wordList = try await mChoiceTestService.getWordList()

        }catch {
            print(error)
        }
        if  wordList?.isEmpty != true {
            return wordList
        }else {
            return nil
        }
    }
    
    //optionlist
    func createOptionList() async -> Set<String>{
        
        var optionList: Set<String> = []
        
        self.wordList =  await getWordList()
      
          if wordList != nil {
              wordList?.forEach({ word in
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
        
        
        wordList?.forEach({ word in
            var randomOptions: [String] = []
            randomOptions.append(word.translatedWords?[0] ?? "")
            
            let filteredOptionList = createdOptionList.filter { $0 != word.translatedWords?[0] }
            randomOptions.append(contentsOf: filteredOptionList.shuffled().prefix(3))
            
            let optionStates: [OptionState] = [.correct, .none, .none, .none]

            let optionModelList = zip(randomOptions, optionStates).map { optionText, optionState in
                OptionModel(optionText: optionText, optionState: optionState)
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
    
    
    
    
}

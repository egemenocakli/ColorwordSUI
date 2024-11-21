//
//  MchoiceTestViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 22.11.2024.
//

import Foundation

class MchoiceTestViewModel: ObservableObject {
    
   let mChoiceTestService = MchoiceTestService()

    //İlk etap
    func getWordList() async {
        var wordList : [Word] = []
        
        do {
            wordList = try await mChoiceTestService.getWordList()

        }catch {
            print(error)
        }
    }
    
    // .. indexe sahip kelimeyi al
    // kelimenin çevirisini optionList e ekle
    // tüm kelime listesindeki kelimelerin çevirilerini al ve random olarak listele
    // bu listeden rastgele 3 tanesini çek, koşul indextekinin çevirisi ile aynı olmayan 3 tanesi
    // optionları tekrar karıştır ve liste olarak sırala
    func makeMchoiceQuestion() {
        
    }
    
    //optionlist
    func createOptionList() {
        
    }
}

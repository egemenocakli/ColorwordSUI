//
//  QuestModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 26.11.2024.
//

import Foundation

class QuestModel {
    var word: Word
    var options: [OptionModel]
    
    init(word: Word, options: [OptionModel]) {
        self.word = word
        self.options = options
    }
}

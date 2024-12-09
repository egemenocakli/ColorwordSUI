//
//  QuestModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 26.11.2024.
//

import Foundation


class OptionModel {
    var optionText: String
    var optionState: OptionState

    init(optionText: String, optionState: OptionState) {
        self.optionText = optionText
        self.optionState = optionState
    }
}

enum OptionState {
    case none
    case correct
    case wrong
}

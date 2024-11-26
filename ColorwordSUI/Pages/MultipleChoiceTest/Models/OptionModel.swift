//
//  QuestModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 26.11.2024.
//

import Foundation


struct OptionModel {
    
    var optionText: String
    var optionState: OptionState
}

enum OptionState {
    case none
    case correct
    case wrong
}

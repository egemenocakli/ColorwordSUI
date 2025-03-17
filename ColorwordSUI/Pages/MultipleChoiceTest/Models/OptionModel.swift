//
//  QuestModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 26.11.2024.
//

import Foundation
import SwiftUICore


class OptionModel: ObservableObject, Identifiable {
    var id = UUID()
    var optionText: String
    var optionState: OptionState
    var buttonColor: Color

    init(optionText: String, optionState: OptionState, buttonColor: Color) {
        self.optionText = optionText
        self.optionState = optionState
        self.buttonColor = buttonColor
    }
}

enum OptionState {
    case none
    case correct
    case wrong
}

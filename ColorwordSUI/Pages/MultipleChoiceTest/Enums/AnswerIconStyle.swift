//
//  AnswerIconStyle.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 14.01.2025.
//

enum AnswerIconStyle {
    case correct
    case wrong
    
    init(isCorrect: Bool) {
        self = isCorrect ? .correct : .wrong
    }
    
    var systemImageName: String {
        switch self {
        case .correct: return Constants.IconTextConstants.correctButton
        case .wrong: return Constants.IconTextConstants.wrongButtonCircle
        }
    }
}

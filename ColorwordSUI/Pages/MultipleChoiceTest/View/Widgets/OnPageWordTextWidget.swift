//
//  onPageWordText.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 21.01.2025.
//

import SwiftUI

struct OnPageWordTextWidget: View {
    var onPageQuestion: QuestModel
    
    var body: some View {
        Text(onPageQuestion.word.word ?? "")
            .fontWeight(.bold)
            .font(.system(size: Constants.FontSizeConstants.x4Large))
            .foregroundStyle(Color.textColorWhite)
    }
}


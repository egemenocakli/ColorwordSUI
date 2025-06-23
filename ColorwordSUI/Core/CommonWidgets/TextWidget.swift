//
//  TextWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 24.06.2025.
//

import SwiftUI

struct TextWidget: View {
     let text: String
    var backgroundColor: Color? = nil
    var font: Font? = nil
    var paddingEdges: Edge.Set = .all
    var paddingValue: CGFloat = Constants.PaddingSizeConstants.smallSize
    var foregroundColor: Color? = nil
    var fontWeight: Font.Weight? = nil
    
    var body: some View {
        Text(LocalizedStringKey(text))
            .foregroundStyle(foregroundColor ?? Constants.ColorConstants.whiteColor)
            .font(font)
            .padding(paddingEdges, paddingValue)
            .background(backgroundColor)
            .fontWeight(fontWeight ?? .medium)
    }
}


//
//  DividerWithTextWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 4.10.2025.
//

import SwiftUI

struct LabeledDivider<Style: ShapeStyle>: View {
    var text: String
    var lineColor: Color = Constants.ColorConstants.grayButtonColor
    var labelBackground: Style   // Color, LinearGradient, .background vs.

    init(
        _ text: String,
        lineColor: Color = Constants.ColorConstants.grayButtonColor,
        labelBackground: Style
    ) {
        self.text = text
        self.lineColor = lineColor
        self.labelBackground = labelBackground
    }

    var body: some View {
        HStack(spacing: 12) {
            line
            Text(text)
                .font(SwiftUI.Font.caption)        // türü netleştirdik
                .foregroundStyle(lineColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                // yazının altına “hap” şeklinde bg:
                .background(
                    Capsule().fill(labelBackground)
                )
            line
        }
        .padding(.horizontal)
    }

    private var line: some View {
        VStack { Divider().overlay(lineColor) }
    }
}

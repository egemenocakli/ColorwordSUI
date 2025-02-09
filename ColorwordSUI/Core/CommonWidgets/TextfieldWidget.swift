//
//  TextfieldWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.02.2025.
//

import SwiftUI

struct TextfieldWidget: View {
    @State var text: String
    var keyboardType: UIKeyboardType?
    var hintText: String?
    var textInputAutoCapitalization: TextInputAutocapitalization?
    
    var body: some View {
        
        
        VStack {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(hintText ?? "")
                        .foregroundColor(Constants.ColorConstants.placeHolderTextColor)
                        .padding(.leading, Constants.PaddingSizeConstants.lmSize)
                }
                TextField("", text: $text)
                    .keyboardType(keyboardType ?? .default)
                    .textInputAutocapitalization(textInputAutoCapitalization ?? .none)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
                    .padding(.all, Constants.PaddingSizeConstants.xSmallSize)
                    .foregroundColor(.white)
            }
        }

    }
}

#Preview {
    TextfieldWidget(text: "", keyboardType: .default)
}

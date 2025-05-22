//
//  FabButton.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 22.05.2025.
//


import SwiftUI

struct FabButton: View {
    let action: () -> Void
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    let buttonImageName: String

    var body: some View {
        HStack{
            Spacer()
            Button(action: action ) {
                Image(systemName: buttonImageName)//Constants.IconTextConstants.addButtonRectangle)
                    .foregroundStyle(foregroundColor)
                    .padding()
                    .background(backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .shadow(radius: Constants.SizeRadiusConstants.buttonShadowRadius)
            }
            .padding(.trailing, Constants.PaddingSizeConstants.fabButtonTrailing)
            .padding(.bottom, Constants.PaddingSizeConstants.fabButtonBottom)
        }
    }
}

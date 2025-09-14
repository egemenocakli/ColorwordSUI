//
//  IconButton.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 13.07.2025.
//

import SwiftUI

struct IconButton: View {
    
    let iconName: String
    let backgroundColor: Color
    let foregroundColor: Color
    let frameWidth: CGFloat
    let frameHeight: CGFloat
    let paddingEdge: Edge.Set
    let paddingValue: CGFloat
    let radius: CGFloat
    let action: () -> Void
    
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: frameWidth, height: frameHeight)
                .padding(8)
        }
        .foregroundStyle(foregroundColor)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: radius))
        .shadow(radius: radius)
        .padding(paddingEdge,paddingValue)
    }
//        var body: some View {
//        Button(action: {
//            //Delete işlemi
//        } ) {
//            Image(systemName: Constants.IconTextConstants.deleteButtonRectangle)
//            .resizable()
//            .scaledToFit()
//            .frame(width: 24, height: 24)
//            .padding(8)
//        }
//        .foregroundStyle(Constants.ColorConstants.buttonForegroundColor)
//        .background(.translateButton)
//        .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xSmall))
//        .shadow(radius: Constants.SizeRadiusConstants.xSmall)
//        .padding(.trailing, 8)
//    }
}

//#Preview {
//    IconButton()
//}

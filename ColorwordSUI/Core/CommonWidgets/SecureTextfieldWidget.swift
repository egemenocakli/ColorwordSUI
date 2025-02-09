//
//  SecureTextfieldWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.02.2025.
//

import SwiftUI

struct SecureTextfieldWidget: View {
    @State var password: String
    
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                if password.isEmpty {
                    Text("login_password")
                        .foregroundColor(Constants.ColorConstants.placeHolderTextColor)
                        .padding(.leading, Constants.PaddingSizeConstants.lmSize)
                }
                SecureField("", text: $password)
                    .textInputAutocapitalization(.none)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small).stroke(Constants.ColorConstants.borderColor, lineWidth: 2))
                    .padding(.all, Constants.PaddingSizeConstants.xSmallSize)
                    .foregroundColor(.white)
            }
        }
        .padding(.bottom, Constants.PaddingSizeConstants.smallSize)
    }
}

#Preview {
    SecureTextfieldWidget(password: "")
}

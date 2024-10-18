//
//  SignUpButtonWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.10.2024.
//

import Foundation
import SwiftUI

struct SignUpButtonWidget: View{
    
    let action: () -> Void
    
    var body: some View{
        signupButtonWidget()
    }
    
    func signupButtonWidget() -> some View {
        Button(action: action) {
            Text("sign_up_button")
                .foregroundStyle(Constants.ColorConstants.whiteFont)
                .frame(width: Constants.ButtonSizeConstants.buttonWidth, height: Constants.ButtonSizeConstants.buttonHeight)
                .background(Constants.ColorConstants.signUpButtonColor)
                .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
        }
        .contentShape(Rectangle())
        .padding(.top, Constants.PaddingSizeConstants.xSmallSize)
    }
}

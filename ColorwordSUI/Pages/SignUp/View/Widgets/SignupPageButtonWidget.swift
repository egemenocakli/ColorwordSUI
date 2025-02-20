//
//  SignupPageButtonWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.02.2025.
//

import SwiftUI

struct SignupPageButtonWidget: View {
    let action: () -> Void

    var body: some View {
       
            Button(action: action) {
                Text("sign_up_button")
                    .foregroundStyle(Constants.ColorConstants.whiteColor)
                    .frame(width: Constants.ButtonSizeConstants.buttonWidth, height: Constants.ButtonSizeConstants.buttonHeight)
                    .background(Constants.ColorConstants.loginButtonColor)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
            }
            .contentShape(Rectangle())
        }
    }


//#Preview {
//    SignupPageButtonWidget()
//}

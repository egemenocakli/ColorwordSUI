//
//  ToastWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 11.02.2025.
//

import SwiftUI

struct ToastWidget: View {
    var message: String
    var body: some View {
        Text(message)
            .padding()
            .background(Constants.ColorConstants.toastMessageBackgroundColor)
            .foregroundColor(Constants.ColorConstants.whiteColor)
            .cornerRadius(Constants.SizeRadiusConstants.xSmall)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20) 
    }
}


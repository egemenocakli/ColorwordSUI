//
//  GoogleLoginButton.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 2.10.2025.
//

import Foundation
import SwiftUI
import UIKit

struct GoogleLoginButton: View{
    
    let action: () -> Void
    
    var body: some View{
        googleLoginButton()
    }
    
    func googleLoginButton() -> some View {
        Button(action: action) {
            HStack{
                Image("googleIconTransparent")
                    .resizable()
                    .renderingMode(.original) // renkleri bozmamak için
                    .frame(width: 24, height: 24)

                Text("login_google")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Constants.ColorConstants.googleLoginFontColor)
                    .padding(.trailing, 8)

            }
            .frame(width: 200, height: 50)
            .background(Constants.ColorConstants.whiteColor)
            .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        )
            .contentShape(Rectangle())
            .padding(.top, Constants.PaddingSizeConstants.xxxxSmallSize)
            .shadow(Constants.AppShadows.button)

            }
        
}

struct PresenterControllerReader: UIViewControllerRepresentable {
    @Binding var controller: UIViewController?

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        // State uyarısı yememek için bir sonraki runloop’ta atıyoruz
        DispatchQueue.main.async { [weak vc] in
            self.controller = vc
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

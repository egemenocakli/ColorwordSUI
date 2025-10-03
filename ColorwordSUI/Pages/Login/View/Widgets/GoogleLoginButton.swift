//
//  GoogleLoginButton.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 2.10.2025.
//

import Foundation
import SwiftUI

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









import SwiftUI
import UIKit
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth // Firebase kullanıyorsan

struct PresenterControllerReader: UIViewControllerRepresentable {
    @Binding var controller: UIViewController?

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        DispatchQueue.main.async { [weak vc] in
            self.controller = vc
        }
        return vc
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}



struct Google_LoginButton: View {
    @State private var presenter: UIViewController?

    var body: some View {
        
        GoogleSignInButton(scheme: .light, style: .wide, state: .normal) {
            Task { await signIn() }
        }
        .frame(width: Constants.ButtonSizeConstants.googleButtonWidth, height: Constants.ButtonSizeConstants.googleButtonHeight)
        .clipShape(RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.small))
        
        .background(PresenterControllerReader(controller: $presenter)) // <-- köprü
        .accessibilityLabel(Text("Google ile devam et"))
    }
    

    @MainActor
    private func signIn() async {
        guard let presenter else { return } // SwiftUI içinden aldığımız VC

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
            // Eğer Firebase ile oturum açacaksan:
            if let idToken = result.user.idToken?.tokenString {
                let accessToken = result.user.accessToken.tokenString
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                _ = try await Auth.auth().signIn(with: credential)
            }
            // result.user.profile?.email, .name vs. erişebilirsin
        } catch {
            print("Google sign-in error:", error)
        }
    }
}


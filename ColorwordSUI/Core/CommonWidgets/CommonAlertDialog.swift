//
//  CommonWidgets.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 24.10.2024.
//

import SwiftUI


struct CommonAlertDialog {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let secondaryButtonTitle: String?
    let primaryAction: () -> Void
    let secondaryAction: () -> Void?
}

//struct CommonAlertDialog: View {
//
//    var titleText: String
//    var messageText: String
//    var buttonText: String
//    var secondButtonText: String
//    
//    var body: some View {
//        Text("")
//            .alert(
//                titleText, // Başlık
//                isPresented: .constant(true),
//                actions: {
//                    Button(buttonText, role: .none) {
//                        // Birincil buton aksiyonu
//                        print("Primary button tapped")
//                    }
//                    Button(secondButtonText, role: .cancel) {
//                        // İptal butonu aksiyonu
//                        print("Secondary button tapped")
//                    }
//                },
//                message: {
//                    Text(messageText) // Mesaj metni
//                }
//            )
//    }
//}
//
//#Preview {
//    CommonAlertDialog(
//        titleText: "Başlık",
//        messageText: "Bu bir uyarı mesajıdır.",
//        buttonText: "Tamam",
//        secondButtonText: "İptal"
//    )
//}

//
//  ProfileView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 5.02.2025.
//

import SwiftUI

struct ProfileView: View {
    
    private let firestoreService = FirestoreService()

    //TODO: buradaki firestore işlemi kaldırılacak.
    var body: some View {
        VStack{
            Text("Profile")
            Divider()
//            Button {
//                if(UserSessionManager.shared.currentUser != nil ) {
//                    firestoreService.createOrUpdateUserInfo(userUid: UserSessionManager.shared.currentUser!.userId, email: UserSessionManager.shared.currentUser!.email, name: UserSessionManager.shared.currentUser!.name, lastName: UserSessionManager.shared.currentUser!.lastname) { result in
//                        print(result)
//                    }
//                }else {
//                    print("başaramadım")
//                }
//                
//            } label: {
//                Text("Kullanıcı Bilgilerini Güncelle")
//            }

        }
    }
}

#Preview {
    ProfileView()
}

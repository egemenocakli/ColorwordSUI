//
//  Firebase.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 21.10.2024.
//

import Foundation
import FirebaseAuth
import UIKit
import FirebaseFirestore
import GoogleSignIn


class FirebaseAuthService: AuthServiceInterface {
    private let firebaseAuth = Auth.auth()
    private var appUser: FirebaseUserModel?
    private var userModel: UserSessionManager?
    private let db = Firestore.firestore()
    
    @Published var isSigningIn = false
    @Published var errorMessage: String?


    @MainActor func getCurrentUser() -> FirebaseUserModel? {
        guard let user = firebaseAuth.currentUser else { return nil }
        appUser = FirebaseUserModel(userId: user.uid, email: user.email ?? "", name: user.displayName ?? "", lastname: "")
        if appUser != nil {
            userModel?.updateUser(with: appUser ?? FirebaseUserModel(userId: user.uid, email: user.email ?? "", name: user.displayName ?? "", lastname: ""))
            
        }
        return appUser
    }

//    func signUpDb(email: String, password: String, name: String, lastName: String, completion: @escaping (Bool,String) -> Void) {
//        firebaseAuth.createUser(withEmail: email, password: password) { authResult, error in
//            if let error = error {
//                print("Sign up error: \(error)")
//                completion(false,"")
//                return
//            }
//            self.appUser = FirebaseUserModel(userId: authResult?.user.uid ?? "", email: email, name: name, lastname: lastName)
//            completion(true, self.appUser?.userId ?? "")
//        }
//    }
    func signUpDb(email: String, password: String, name: String, lastName: String, completion: @escaping (ServiceResponse<String>) -> Void) {
        firebaseAuth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(.firebaseError(error.localizedDescription))) // 🔥 Hata durumu artık doğru!
                return
            }
            
            guard let userId = authResult?.user.uid else {
                completion(.failure(.unknownError)) // 🔥 Kullanıcı ID boşsa hata dön
                return
            }
            
            completion(.success(userId)) // ✅ Kullanıcı ID başarıyla döndürülüyor
        }
    }


    
    func loginWithEmailPassword(email: String, password: String, completion: @escaping (ServiceResponse<FirebaseUserModel>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("❌ Giriş yapılamadı: \(error.localizedDescription)")
                completion(.failure(.firebaseError(error.localizedDescription)))
                return
            }
            
            guard let authResult = authResult else {
                completion(.failure(.unknownError))
                return
            }
            
            let user = authResult.user
            let userNameLastname = self.splitName(from: user.displayName ?? "")
            
            let firebaseUser = FirebaseUserModel(
                userId: user.uid,
                email: user.email ?? "",
                name: userNameLastname.name,
                lastname: userNameLastname.lastName
            )
            
            print("✅ Kullanıcı giriş yaptı: \(firebaseUser.email)")
            completion(.success(firebaseUser))
        }
    }

    /// **Kullanıcının ismini ve soyismini ayıran yardımcı metod**
    private func splitName(from displayName: String) -> (name: String, lastName: String) {
        let nameComponents = displayName.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        let name = nameComponents.first.map(String.init) ?? ""
        let lastName = nameComponents.count > 1 ? String(nameComponents[1]) : ""
        return (name, lastName)
    }
    
    @MainActor
    func signInWithGoogle(presenter: UIViewController) async {
        isSigningIn = true; defer { isSigningIn = false }
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "Auth", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "ID token alınamadı"])
            }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )

            let authResult = try await Auth.auth().signIn(with: credential)
            let u = authResult.user

            // Kullanıcıyı UserSessionManager'a yaz
            let firebaseUser = FirebaseUserModel(
                userId: u.uid,
                email: u.email ?? "",
                name: u.displayName ?? "",
                lastname: "",
            )
            UserSessionManager.shared.updateUser(with: firebaseUser)

            // /users kök dokümanını (opsiyonel) güncelle ya da oluştur
            try await db.collection("users").document(u.uid).setData([
                "userId": u.uid,
                "email": u.email ?? "",
                "displayName": u.displayName ?? "",
                "provider": "google",
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)

            // 🔽 Asıl kritik kısım: userInfo’yu getir veya oluştur
            let info = try await fetchOrCreateUserInfo(
                userId: u.uid,
                name: u.displayName ?? "",
                email: u.email ?? ""
    
                
            )
            UserSessionManager.shared.updateUserInfoModel(with: info)

        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    func fetchOrCreateUserInfo(userId: String,
                                   name: String,
                                   email: String) async throws -> UserInfoModel {
            let docRef = db.collection("users")
                .document(userId)
                .collection("userInfo")
                .document("userInfo")

            // 1) Oku
            let snap = try await docRef.getDocument()
            if snap.exists {
                // Codable ise:
                if let info = try? snap.data(as: UserInfoModel.self) {
                    return info
                }
                // Codable değilse manuel parse et:
                let data = snap.data() ?? [:]
                return UserInfoModel(
                    userId: userId,
                    email: data["email"] as? String ?? email,
                    name: data["name"] as? String ?? name,
                    lastname: data["lastname"] as? String ?? "",
                    dailyTarget: data["dailyTarget"] as? Int ?? Constants.ScoreConstants.dailyTargetScore,
                    dailyScore: data["dailyScore"] as? Int ?? 0
                )
            }

            // 2) Yoksa oluştur (varsayılan dailyTarget ile)
            let newInfo = UserInfoModel(
                userId: userId,
                email: email,
                name: name,
                lastname: "",
                dailyTarget: Constants.ScoreConstants.dailyTargetScore,
                dailyScore: 10
            )

            // Codable ise:
            // try await docRef.setData(from: newInfo, merge: true)

            // Codable değilse:
            try await docRef.setData([
                "userId": newInfo.userId,
                "email": newInfo.email,
                "name": newInfo.name,
                "lastname": newInfo.lastname,
                "dailyTarget": newInfo.dailyTarget,
                "dailyScore": newInfo.dailyScore,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)

            return newInfo
        }

    
//    
//    
//    func signInWithGoogle(completion: @escaping (FirebaseUserModel?) -> Void) {
//        
////        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
//        
////        let signInConfig = GIDConfiguration(clientID: clientID)
////        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: UIApplication.shared.windows.first!.rootViewController!) { user, error in
////            if let error = error {
////                print("Google Sign-In error: \(error)")
////                completion(nil)
////                return
////            }
////
////            guard let authentication = user?.authentication,
////                  let idToken = authentication.idToken else {
////                completion(nil)
////                return
////            }
////
////            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
////            self.firebaseAuth.signIn(with: credential) { authResult, error in
////                if let error = error {
////                    print("Firebase Sign-In error: \(error)")
////                    completion(nil)
////                    return
////                }
////                if let user = authResult?.user {
////                    self.appUser = FirebaseUserModel(userId: user.uid, email: user.email ?? "", name: user.displayName ?? "", lastname: "")
////                    completion(self.appUser)
////                }
////            }
////        }
////
//    }
//
    func signOut(completion: @escaping (Bool) -> Void) {
        do {
            try firebaseAuth.signOut()
            completion(true)
        } catch {
            print("Sign out error: \(error)")
            completion(false)
        }
    }
    
    
    
    
//
//    func updateName(displayName: String, completion: @escaping (Bool) -> Void) {
////        firebaseAuth.currentUser?.updateDisplayName(displayName) { error in
////            completion(error == nil)
////        }
//    }
//
//    func updateEmail(email: String, completion: @escaping (Bool) -> Void) {
////        firebaseAuth.currentUser?.updateEmail(to: email) { error in
////            completion(error == nil)
////        }
//    }
//
//    func deleteAccount(completion: @escaping (Bool) -> Void) {
//        firebaseAuth.currentUser?.delete { error in
//            completion(error == nil)
//        }
//    }

}

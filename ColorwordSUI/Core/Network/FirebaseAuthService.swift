//
//  Firebase.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 21.10.2024.
//

import Foundation
import FirebaseAuth
//import GoogleSignIn

class FirebaseAuthService: AuthServiceInterface {
    private let firebaseAuth = Auth.auth()
    private var appUser: FirebaseUserModel?
    private var userModel: UserSessionManager?

    func getCurrentUser() -> FirebaseUserModel? {
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

//
//  SignupService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 10.02.2025.
//

protocol SignupInterface {
    func signUp(email: String, password: String, name: String, lastName: String, completion: @escaping (ServiceResponse<String>) -> Void)
    func createUserInfo(email: String, name: String, lastName: String, userId: String, completion: @escaping (ServiceResponse<Bool>) -> Void)
}

class SignupService: FirebaseAuthService, SignupInterface {

    private let firebaseAuthService = FirebaseAuthService()
    private let firestoreService = FirestoreService()

    /// **Kullanıcıyı Firebase Authentication ile kaydeder ve Firestore'a kaydeder**
    func signUp(email: String, password: String, name: String, lastName: String, completion: @escaping (ServiceResponse<String>) -> Void) {
        
        firebaseAuthService.signUpDb(email: email, password: password, name: name, lastName: lastName) { response in
            switch response {
            case .success(let userId):
                print("✅ Kullanıcı başarıyla kaydedildi. Firestore'a ekleniyor...")

                self.createUserInfo(email: email, name: name, lastName: lastName, userId: userId) { firestoreResult in
                    switch firestoreResult {
                    case .success:
                        completion(.success(userId)) // 🎉 Kullanıcı hem Authentication hem Firestore'da oluşturuldu
                    case .failure(let error):
                        completion(.failure(error)) // ❌ Firestore kaydında hata oldu
                    }
                }

            case .failure(let error):
                print("❌ Firebase Authentication Hatası: \(error.localizedDescription)")
                completion(.failure(error)) // ❌ Firebase Auth hata döndü
            }
        }
    }

    /// **Kullanıcı bilgilerini Firestore’a ekler. UserInfo bilgisi olarak bir model daha tutuluyor, bu bilgileri burada model içeriğini dolduruyoruz**
    func createUserInfo(email: String, name: String, lastName: String, userId: String, completion: @escaping (ServiceResponse<Bool>) -> Void) {
        
        firestoreService.createOrUpdateUserInfo(user: UserInfoModel(userId: userId, email: email, name: name, lastname: lastName)) { success in
            if success {
                print("✅ Firestore'da kullanıcı bilgileri başarıyla kaydedildi.")
                completion(.success(true))
            } else {
                print("❌ Firestore'da kullanıcı bilgileri kaydedilemedi!")
                completion(.failure(.firestoreError("Kullanıcı bilgileri kaydedilemedi.")))
            }
        }
    }

}



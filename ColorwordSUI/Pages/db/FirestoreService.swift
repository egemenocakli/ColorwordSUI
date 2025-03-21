//
//  FirestoreService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 12.11.2024.
//

import Foundation
import FirebaseFirestore

class FirestoreService: FirestoreInterface {
    
   private let db = Firestore.firestore()
    
        
        func getWordList() async throws -> [Word] {
            // Kullanıcı ID'si kontrolü
            guard let userId = UserSessionManager.shared.currentUser?.userId else {
                throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
            }
            
            var words: [Word] = []
            
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("words")
                .getDocuments()
            
            for document in snapshot.documents {
                if let word = Word(fromMap: document.data()) {
                    words.append(word)
                }
            }
                        
            return words.isEmpty ? [] : words
        }
    
    
        func increaseWordScore(word: Word, points: Int) async throws{
            
            guard let userId = UserSessionManager.shared.currentUser?.userId else {
                throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
            }
            do {
                try await db.collection("users").document(userId).collection("words").document(word.wordId!).updateData(word.toMap())
            }
            catch {
                print(error)
            }
        }
        func decreaseWordScore(word: Word, points: Int) async throws{
            
            guard let userId = UserSessionManager.shared.currentUser?.userId else {
                throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
            }
            do {
                try await db.collection("users").document(userId).collection("words").document(word.wordId!).updateData(word.toMap())
            }
            catch {
                print(error)
            }
        }
    
    
       
//    func createOrUpdateUserInfo(userUid: String, email: String, name: String, lastName: String, completion: @escaping (Bool) -> Void) {
//        
//        let docRef = db.collection("users").document(userUid)
//                       .collection("userInfo")
//                       .document("userInfo") 
//        
//        let data: [String: Any] = [
//            "userId": userUid,
//            "email": email,
//            "name": name,
//            "lastname": lastName,
//            "photo": "empty",
//            "totalScore": 0,
//            "dailyScore": 0,
//            "dailyScoreDate": FieldValue.serverTimestamp()
//        ]
//        
//        docRef.setData(data) { error in
//            if let error = error {
//                print("❌ Firestore hata: \(error.localizedDescription)")
//                completion(false)
//            } else {
//                print("✅ userInfo belgesi başarıyla oluşturuldu/güncellendi.")
//                completion(true)
//            }
//        }
//    }
    func createOrUpdateUserInfo(user: UserInfoModel, completion: @escaping (Bool) -> Void) {
        
        let docRef = db.collection("users").document(user.userId)
                       .collection("userInfo")
                       .document("userInfo")
        
        let data = user.toDictionary()
        
        docRef.setData(data) { error in
            if let error = error {
                print("❌ Firestore hata: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ userInfo belgesi başarıyla oluşturuldu/güncellendi.")
                completion(true)
            }
        }
    }

    //UserInfo bilgisini çek eğer yoksa oluştur dedik.
    func fetchUserInfo (userId: String, completion: @escaping (UserInfoModel?) -> Void) {
        let docRef = db.collection("users").document(userId).collection("userInfo").document("userInfo")
        
        docRef.getDocument { snapshot, error in
            if let error = error {
                print("❌ Firestore hata: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = snapshot?.data() else {
                print("❌ Belge bulunamadı. Oluşturulacak metoda yönlendirildi.")
                
                self.createOrUpdateUserInfo(user: UserInfoModel(userId: UserSessionManager.shared.currentUser!.userId, email: UserSessionManager.shared.currentUser!.email, name: UserSessionManager.shared.currentUser!.name, lastname: UserSessionManager.shared.currentUser!.lastname)) { success in
                    
                    if success {
                        completion(nil)
                    }
                    else {
                        completion(nil)
                    }
                }
                
                completion(nil)
                return
            }
            
            if let userInfo = UserInfoModel(dictionary: data, docId: snapshot!.documentID) {
                completion(userInfo)
            } else {
                completion(nil)
            }
        }
    }

    func increaseDailyPoints(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void) {
        
        guard !userInfo.userId.isEmpty else {
            print("❌ Geçersiz userInfo, userId boş!")
            completion(false)
            return
        }
        
        let docRef = db.collection("users").document(userInfo.userId)
            .collection("userInfo")
            .document("userInfo")
        
        let updates : [String : Any] = [
            "dailyScore" : userInfo.dailyScore,
            "totalScore" : userInfo.totalScore,
            "dailyScoreDate" : FieldValue.serverTimestamp()
            ]
        docRef.updateData(updates) { error in
            
            if let error = error {
                print("❌ Update error: \(error.localizedDescription)")
                completion(false)
            }else {
                print("✅ Skor bilgileri başarıyla güncellendi.")
                completion(true)
                }
            
            }
        
        }
    
    func resetDailyScore(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void) {
        
        guard !userInfo.userId.isEmpty else {
            print("❌ Geçersiz userInfo, userId boş!")
            completion(false)
            return
        }
        
        let docRef = db.collection("users").document(userInfo.userId)
            .collection("userInfo")
            .document("userInfo")
        
        let updates : [String : Any] = [
            "dailyScore" : userInfo.dailyScore,
            "totalScore" : userInfo.totalScore
            ]
        docRef.updateData(updates) { error in
            
            if let error = error {
                print("❌ Update error: \(error.localizedDescription)")
                completion(false)
            }else {
                print("✅ Skor bilgileri başarıyla güncellendi.")
                completion(true)
                }
            
            }
        
        }

    }

    
    
    


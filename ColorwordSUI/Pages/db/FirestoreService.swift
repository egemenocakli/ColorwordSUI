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
    
    //zaman alabilecek bir işlem await vs eklenecek. bu yüzden anasayfaya beklenmesi gerekecek şekilde uygulanacak
        
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
    
    
       
    func createUserInfo(email: String, name: String, lastName: String, userUid: String, completion: @escaping (Bool) -> Void) {

        let userInfo: [String: Any] = [
            "userId": userUid,
            "email": email,
            "name": name,
            "lastname": lastName,
            "photo": "empty"
        ]
        
        db.collection("users").document(userUid).collection("userInfo").addDocument(data: userInfo) { error in
            if let error = error {
                print("❌ Firestore createUserInfo hatası: \(error.localizedDescription)")
                completion(false) // Hata oldu, başarısız sonucu döndür
            } else {
                print("✅ Kullanıcı bilgileri Firestore'a başarıyla eklendi!")
                completion(true) // Başarıyla kaydedildi
            }
        }
    }

    
    }

    
    
    


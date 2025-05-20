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
    
    //TODO: Yeni oluşturulan dizin için yeni kelime ekle sayfası vs. yapılacak.
    //TODO: Asenkron metodlara geçilecek
    func getWordList() async throws -> [Word] {
        // Kullanıcı ID'si kontrolü
        guard let userId = UserSessionManager.shared.currentUser?.userId else {
            throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }
        
        var words: [Word] = []
        
        
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("wordLists")
            .document("wordLists")
            .collection("userWords")
            .getDocuments()
        
        for document in snapshot.documents {
            if let word = Word(fromMap: document.data()) {
                words.append(word)
            }
        }
        
        return words
    }
    
    
    func increaseWordScore(word: Word, points: Int) async throws{
        
        guard let userId = UserSessionManager.shared.currentUser?.userId else {
            throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }
        do {
            try await db.collection("users").document(userId)
                .collection("wordLists")
                .document("wordLists")
                .collection("userWords")
                .document(word.wordId!).updateData(word.toMap())
        }
        catch {
            debugPrint(error)
        }
    }
    func decreaseWordScore(word: Word, points: Int) async throws{
        
        guard let userId = UserSessionManager.shared.currentUser?.userId else {
            throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }
        do {
            try await db.collection("users").document(userId)
                .collection("wordLists")
                .document("wordLists")
                .collection("userWords")
                .document(word.wordId!).updateData(word.toMap())
        }
        catch {
            debugPrint(error)
        }
    }
    
    func createOrUpdateUserInfo(user: UserInfoModel, completion: @escaping (Bool) -> Void) {
        
        let docRef = db.collection("users").document(user.userId)
            .collection("userInfo")
            .document("userInfo")
        
        let data = user.toDictionary()
        
        docRef.setData(data) { error in
            if let error = error {
                debugPrint("❌ Firestore hata: \(error.localizedDescription)")
                completion(false)
            } else {
                debugPrint("✅ userInfo belgesi başarıyla oluşturuldu/güncellendi.")
                completion(true)
            }
        }
    }
    
    //UserInfo bilgisini çek eğer yoksa oluştur dedik.
    func fetchUserInfo (userId: String, completion: @escaping (UserInfoModel?) -> Void) {
        let docRef = db.collection("users").document(userId).collection("userInfo").document("userInfo")
        
        docRef.getDocument { snapshot, error in
            if let error = error {
                debugPrint("❌ Firestore hata: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = snapshot?.data() else {
                debugPrint("❌ Belge bulunamadı. Oluşturulacak metoda yönlendirildi.")
                
                self.createOrUpdateUserInfo(user: UserInfoModel(
                    userId: UserSessionManager.shared.currentUser!.userId,
                    email: UserSessionManager.shared.currentUser!.email,
                    name: UserSessionManager.shared.currentUser!.name,
                    lastname: UserSessionManager.shared.currentUser!.lastname,
                    dailyTarget: Constants.ScoreConstants.dailyTargetScore, dailyScore: 10
                )) { success in
                    completion(nil)
                }
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
            debugPrint("❌ Geçersiz userInfo, userId boş!")
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
                debugPrint("❌ Update error: \(error.localizedDescription)")
                completion(false)
            }else {
                debugPrint("✅ Skor bilgileri başarıyla güncellendi.")
                completion(true)
            }
            
        }
        
    }
    
    func resetDailyScore(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void) {
        
        guard !userInfo.userId.isEmpty else {
            debugPrint("❌ Geçersiz userInfo, userId boş!")
            completion(false)
            return
        }
        
        let docRef = db.collection("users").document(userInfo.userId)
            .collection("userInfo")
            .document("userInfo")
        
        let updates : [String : Any] = [
            "dailyScore" : userInfo.dailyScore
        ]
        docRef.updateData(updates) { error in
            
            if let error = error {
                debugPrint("❌ Update error: \(error.localizedDescription)")
                completion(false)
            }else {
                debugPrint("✅ Skor bilgileri başarıyla güncellendi.")
                completion(true)
            }
            
        }
        
    }
    
    
    func changeDailyTarget(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void) {
        
        
        guard !userInfo.userId.isEmpty else {
            debugPrint("❌ Geçersiz userInfo, userId boş!")
            completion(false)
            return
        }
        
        let docRef = db.collection("users").document(userInfo.userId)
            .collection("userInfo")
            .document("userInfo")
        
        let updates : [String : Any] = [
            "dailyTarget" : userInfo.dailyTarget,
        ]
        docRef.updateData(updates) { error in
            
            if let error = error {
                debugPrint("❌ Update error: \(error.localizedDescription)")
                completion(false)
            }else {
                
                debugPrint("✅ Günlük skor hedefiniz \(userInfo.dailyTarget) olarak başarıyla güncellendi.")
                completion(true)
            }
            
        }
        
    }
    
    func getAzureK() async throws -> String? {
        let documentRef = db.collection("infos").document("sUbzxOQNmxGTATsDfh35")
        
        let documentSnapshot = try await documentRef.getDocument()
        
        if let data = documentSnapshot.data(), let azureK = data["azureK"] as? String {
            return azureK
        } else {
            return nil
        }
    }
    
    func saveFavoriteLanguages(for languageWrapper: LanguageListWrapper, for userInfo: UserInfoModel?) async throws {
        
        guard let userId = userInfo?.userId else {
            throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }
        
        let docRef = db.collection("users")
            .document(userId)
            .collection("userFavoriteLanguages")
            .document("userFavoriteLanguages")
        
        let snapshot = try await docRef.getDocument()
        var existingLanguages: [Language] = []
        
        if snapshot.exists {
            if let decodedWrapper = try? snapshot.data(as: LanguageListWrapper.self) {
                existingLanguages = decodedWrapper.languages
            }
        }
        
        // Yeni dillerden zaten eklenmiş olanları filtrele
        let existingIDs = Set(existingLanguages.map { $0.id })
        let filteredNewLanguages = languageWrapper.languages.filter { !existingIDs.contains($0.id) }
        
        guard !filteredNewLanguages.isEmpty else {
            debugPrint("Yeni eklenecek dil yok.")
            return
        }
        
        let merged = existingLanguages + filteredNewLanguages
        let mergedWrapper = LanguageListWrapper(languages: merged)
        try await docRef.setData(from: mergedWrapper)
        debugPrint("favori dil \(filteredNewLanguages.count) eklendi")
    }
    
    
    func getFavoriteLanguages(for userInfo: UserInfoModel?) async throws -> LanguageListWrapper {
        guard let userId = userInfo?.userId else {
            throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }
        
        let docRef = db.collection("users")
            .document(userId)
            .collection("userFavoriteLanguages")
            .document("userFavoriteLanguages")
        
        let snapshot = try await docRef.getDocument()
        if snapshot.exists, let decodedWrapper = try? snapshot.data(as: LanguageListWrapper.self) {
            return decodedWrapper
        }else {
            return LanguageListWrapper(languages: [])
        }
    }
}

    
    

/*
 
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
                 debugPrint(error)
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
                 debugPrint(error)
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
 //                debugPrint("❌ Firestore hata: \(error.localizedDescription)")
 //                completion(false)
 //            } else {
 //                debugPrint("✅ userInfo belgesi başarıyla oluşturuldu/güncellendi.")
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
                 debugPrint("❌ Firestore hata: \(error.localizedDescription)")
                 completion(false)
             } else {
                 debugPrint("✅ userInfo belgesi başarıyla oluşturuldu/güncellendi.")
                 completion(true)
             }
         }
     }

     //UserInfo bilgisini çek eğer yoksa oluştur dedik.
     func fetchUserInfo (userId: String, completion: @escaping (UserInfoModel?) -> Void) {
         let docRef = db.collection("users").document(userId).collection("userInfo").document("userInfo")
         
         docRef.getDocument { snapshot, error in
             if let error = error {
                 debugPrint("❌ Firestore hata: \(error.localizedDescription)")
                 completion(nil)
                 return
             }
             guard let data = snapshot?.data() else {
                 debugPrint("❌ Belge bulunamadı. Oluşturulacak metoda yönlendirildi.")
                 
                 self.createOrUpdateUserInfo(user: UserInfoModel(
                     userId: UserSessionManager.shared.currentUser!.userId,
                     email: UserSessionManager.shared.currentUser!.email,
                     name: UserSessionManager.shared.currentUser!.name,
                     lastname: UserSessionManager.shared.currentUser!.lastname,
                     dailyTarget: Constants.ScoreConstants.dailyTargetScore, dailyScore: 10
                 )) { success in
                     completion(nil)
                 }
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
             debugPrint("❌ Geçersiz userInfo, userId boş!")
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
                 debugPrint("❌ Update error: \(error.localizedDescription)")
                 completion(false)
             }else {
                 debugPrint("✅ Skor bilgileri başarıyla güncellendi.")
                 completion(true)
                 }
             
             }
         
         }
     
     func resetDailyScore(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void) {
         
         guard !userInfo.userId.isEmpty else {
             debugPrint("❌ Geçersiz userInfo, userId boş!")
             completion(false)
             return
         }
         
         let docRef = db.collection("users").document(userInfo.userId)
             .collection("userInfo")
             .document("userInfo")
         
         let updates : [String : Any] = [
             "dailyScore" : userInfo.dailyScore
         ]
         docRef.updateData(updates) { error in
             
             if let error = error {
                 debugPrint("❌ Update error: \(error.localizedDescription)")
                 completion(false)
             }else {
                 debugPrint("✅ Skor bilgileri başarıyla güncellendi.")
                 completion(true)
                 }
             
             }
         
         }

     
     func changeDailyTarget(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void) {
         
         
         guard !userInfo.userId.isEmpty else {
             debugPrint("❌ Geçersiz userInfo, userId boş!")
             completion(false)
             return
         }
         
         let docRef = db.collection("users").document(userInfo.userId)
             .collection("userInfo")
             .document("userInfo")
         
         let updates : [String : Any] = [
             "dailyTarget" : userInfo.dailyTarget,
             ]
         docRef.updateData(updates) { error in
             
             if let error = error {
                 debugPrint("❌ Update error: \(error.localizedDescription)")
                 completion(false)
             }else {
                 
                 debugPrint("✅ Günlük skor hedefiniz \(userInfo.dailyTarget) olarak başarıyla güncellendi.")
                 completion(true)
                 }
             
             }
         
         }
     }

     
     
     


 */

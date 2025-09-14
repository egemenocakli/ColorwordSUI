//
//  FirestoreService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 12.11.2024.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class FirestoreService: FirestoreInterface {

    
    
    
    private let db = Firestore.firestore()
    
    //TODO: Asenkron metodlara geçilecek
    func getWordList(wordListname: String) async throws -> [Word] {
        // Kullanıcı ID'si kontrolü
        guard let userId = UserSessionManager.shared.currentUser?.userId else {
            throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }
        
        var words: [Word] = []
        
        
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("wordLists")
            .document(wordListname)
            .collection("userWords")
            .getDocuments()
        
        for document in snapshot.documents {
            if let word = Word(fromMap: document.data()) {
                words.append(word)
            }
        }
        
        return words
    }
    
    
    func increaseWordScore(selectedWordList: String,word: Word, points: Int) async throws{
        
        guard let userId = UserSessionManager.shared.currentUser?.userId else {
            throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }
        do {
            try await db.collection("users").document(userId)
                .collection("wordLists")
                .document(selectedWordList)
                .collection("userWords")
                .document(word.wordId!).updateData(word.toMap())
        }
        catch {
            debugPrint(error)
        }
    }
    func decreaseWordScore(selectedWordList: String,word: Word, points: Int) async throws{
        
        guard let userId = UserSessionManager.shared.currentUser?.userId else {
            throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }
        do {
            try await db.collection("users").document(userId)
                .collection("wordLists")
                .document(selectedWordList)
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
    //TODO: kişinin başka kelime listesi var mı?
    //Aşağıdakini sadece başka kelime listesi yoksa diye yapıyorum. bir benzerini daha yapıp onda parametre falan almalıyım hangi listeye ekleyeceğine dair.
    func addNewWord(word: Word, userInfo: UserInfoModel?, selectedUserWordList: String?) async throws {
        
        guard let userId = userInfo?.userId else {
            throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }
        
        let collectionRef = db.collection("users")
            .document(userId)
            .collection("wordLists")
            .document(selectedUserWordList ?? "wordLists")
            .collection("userWords")

        
        let newDoc = collectionRef.document()
        var toSave = word
        let randomColor = Color.random
        
        toSave.wordId = newDoc.documentID
        let now = Timestamp(date: Date())
        toSave.addDate = now
        toSave.lastUpdateDate = now
        toSave.color = randomColor
        toSave.photoURL = ""
        try await newDoc.setData(toSave.toMap())
        debugPrint("🔥 Yeni kelime eklendi: \(toSave.wordId ?? "")")
        debugPrint("🔥 Yeni kelime translatedWords: \(toSave.translatedWords?[0] ?? "")")

    }
    
    //User word groups
    func getSharedWordGroups(userInfo: UserInfoModel?) async throws -> [String] {
        
        
        let snapshot = try await db.collection("sharedWordLists")
            .getDocuments()


        let documentIDs = snapshot.documents.map { $0.documentID }
        debugPrint("Hazır Kelime listeleri:", documentIDs)
        return documentIDs
    }
    
    //User word groups
    func getWordGroups(userInfo: UserInfoModel?) async throws -> [String] {
        
        guard let userId = userInfo?.userId else {
            throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }
        
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("wordLists")
            .order(by: "order")
            .getDocuments()


        let documentIDs = snapshot.documents.map { $0.documentID }
        debugPrint("Kelime listeleri:", documentIDs)
        return documentIDs
    }
    ///Kelime listelerini en son seçilenin order değişekinin değerini 0 diğerlerini ise 1 olarak düzenler.
    ///Böylece kişinin en son seçtiğini sonraki açılışta seçili olarak gösterir.
    func orderWordGroup(languageListName: String, userInfo: UserInfoModel?) async throws {
        guard let userId = userInfo?.userId else {
            throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }

        let collectionRef = db.collection("users")
            .document(userId)
            .collection("wordLists")

        // 1️⃣ Tüm belgeleri çek
        let snapshot = try await collectionRef.getDocuments()

        // 2️⃣ Batch ile toplu güncelleme başlat
        let batch = db.batch()

        for doc in snapshot.documents {
            let ref = doc.reference
            let orderValue = (doc.documentID == languageListName) ? 0 : 1

            batch.setData([
                "order": orderValue
            ], forDocument: ref, merge: true)
        }

        try await batch.commit()
    }
    
    //User word groups
    func createWordGroup(languageListName: String,userInfo: UserInfoModel?) async throws  {
        
        guard let userId = userInfo?.userId else {
            throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }
        
        let parentDocRef = db.collection("users")
            .document(userId)
            .collection("wordLists")
            .document(languageListName)
        
        let documentSnapshot = try await parentDocRef.getDocument()
        guard !documentSnapshot.exists else {
            debugPrint("'\(languageListName)' adlı kelime grubu zaten mevcut, tekrar oluşturulmadı.")
            return
        }

        // En az bir alan set et (örneğin tarih veya isim)
        try await parentDocRef.setData([
            "name": languageListName,
            "order": 1
        ])
        
        let subCollectionRef = parentDocRef.collection("userWords")
        let newDoc = subCollectionRef.document()
        
        let newWord = Word(word: "First Word")
        var toSave = newWord
        let randomColor = Color.random
        
        toSave.wordId = newDoc.documentID
        let now = Timestamp(date: Date())
        toSave.addDate = now
        toSave.lastUpdateDate = now
        toSave.color = randomColor
        toSave.photoURL = ""
        
        
        toSave.translatedWords = ["ilk kelime"]
        toSave.sourceLanguageId = "tr"
        toSave.translateLanguageId = "en"
        
        try await newDoc.setData(toSave.toMap())
            
    }
    
    //Kayıtlı favori dil listelerini silebilecek.
    func deleteWordGroup(named languageListName: String, userInfo: UserInfoModel?) async throws {
        guard let userId = userInfo?.userId else {
            throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }

        let documentRef = db.collection("users")
            .document(userId)
            .collection("wordLists")
            .document(languageListName)

        // Alt koleksiyonu sil
        let subCollectionRef = documentRef.collection("userWords") // Sabit ad gibi görünüyor
        let snapshot = try await subCollectionRef.getDocuments()
        
        for doc in snapshot.documents {
            try await subCollectionRef.document(doc.documentID).delete()
        }

        // Ana dökümanı sil
        try await documentRef.delete()
        
        debugPrint("'\(languageListName)' adlı kelime grubu ve alt verileri silindi.")
    }

    
    func updateLeaderboardScore(by score: Int, userInfo: UserInfoModel?) async throws {
        guard let userId = userInfo?.userId else {
            throw NSError(domain: "FirestoreService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }

        let name = userInfo?.name ?? ""
        let lastname = userInfo?.lastname ?? ""
        let inc  = FieldValue.increment(Int64(score))
        let payload: [String: Any] = [
            "userId": userId,
            "displayName": name,
            "lastName": lastname,
            "score": inc,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        let allTimeRef = db.collection("leaderboards").document("global-alltime")
            .collection("entries").document(userId)

        let weeklyRef = db.collection("leaderboards").document("global-weekly")
            .collection("entries").document(userId)

        let dailyRef = db.collection("leaderboards").document("global-daily")
            .collection("entries").document(userId)

        // Üç yazımı paralel yap
        async let w1: Void = allTimeRef.setData(payload, merge: true)
        async let w2: Void = weeklyRef.setData(payload, merge: true)
        async let w3: Void = dailyRef.setData(payload, merge: true)
        _ = try await (w1, w2, w3)
    }


}

extension FirestoreService {
    /// Top N + kullanıcının kendisi (listede yoksa sona ekler).
    func getLeaderboardScores(
        limit: Int = 10,
        alsoInclude userId: String?,
        scope: LeaderboardScope = .alltime
    ) async throws -> LeaderboardResult {

        let baseRef = db.collection("leaderboards")
            .document("global-alltime")
            .collection("entries")

        let query = baseRef
            .order(by: "score", descending: true)
            .limit(to: limit)

        // Paralel çekelim
        async let topSnapshotTask = query.getDocuments()
        async let meSnapshotTask: DocumentSnapshot? = {
            guard let userId else { return nil }
            return try? await baseRef.document(userId).getDocument()
        }()

        let topSnapshot = try await topSnapshotTask
        var top = try topSnapshot.documents.map { try $0.data(as: LeaderboardEntry.self) }

        var me: LeaderboardEntry? = nil
        if let userId, let meSnap = try await meSnapshotTask, meSnap.exists {
            let myEntry = try meSnap.data(as: LeaderboardEntry.self)

            // Zaten top listede varsa tekrar ekleme
            if top.contains(where: { $0.userId == userId }) {
                me = top.first(where: { $0.userId == userId })
            } else {
                me = myEntry
                top.append(myEntry) // Top N + 1 (kullanıcı)
            }
        }

        return LeaderboardResult(top: top, me: me)
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

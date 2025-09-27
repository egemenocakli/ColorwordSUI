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

        // Delete subCollection
        let subCollectionRef = documentRef.collection("userWords") // Sabit ad gibi görünüyor
        let snapshot = try await subCollectionRef.getDocuments()
        
        for doc in snapshot.documents {
            try await subCollectionRef.document(doc.documentID).delete()
        }

        // Delete main doc
        try await documentRef.delete()
        
        debugPrint("'\(languageListName)' adlı kelime grubu ve alt verileri silindi.")
    }

    // Helper: Tomorrow at 00:00 (Istanbul time zone)
    func nextDayCutoffDate(timeZone: TimeZone = TimeZone(identifier: "Europe/Istanbul")!) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        let startOfToday = cal.startOfDay(for: Date())
        return cal.date(byAdding: .day, value: 1, to: startOfToday)!
    }

    // Helper: Next Monday at 00:00 (Istanbul time zone).
    func nextWeekCutoffDate(timeZone: TimeZone = TimeZone(identifier: "Europe/Istanbul")!) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        cal.firstWeekday = 2  // Pazartesi
        let startOfThisWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return cal.date(byAdding: .weekOfYear, value: 1, to: startOfThisWeek)!
    }

    // UPDATE Leaderboard
    func updateLeaderboardScore(by delta: Int, userInfo: UserInfoModel?) async throws {
        guard let u = userInfo else {
            throw NSError(domain: "FirestoreService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Geçerli bir kullanıcı bulunamadı."])
        }

        let userId   = u.userId
        let name     = u.name
        let lastName = u.lastname

        let allTimeRef = db.collection("leaderboards").document("global-alltime")
            .collection("entries").document(userId)
        let weeklyRef  = db.collection("leaderboards").document("global-weekly")
            .collection("entries").document(userId)
        let dailyRef   = db.collection("leaderboards").document("global-daily")
            .collection("entries").document(userId)

        let dailyExpTS  = Timestamp(date: nextDayCutoffDate())
        let weeklyExpTS = Timestamp(date: nextWeekCutoffDate())

        async let t1: () = upsertScoreTransaction(ref: allTimeRef,
                                              delta: delta,
                                              displayName: name,
                                              lastName: lastName,
                                              expiresAt: nil)                 // all-time: expiry yok
        async let t2: () = upsertScoreTransaction(ref: weeklyRef,
                                              delta: delta,
                                              displayName: name,
                                              lastName: lastName,
                                              expiresAt: weeklyExpTS)         // weekly
        async let t3: () = upsertScoreTransaction(ref: dailyRef,
                                              delta: delta,
                                              displayName: name,
                                              lastName: lastName,
                                              expiresAt: dailyExpTS)          // daily
        _ = try await (t1, t2, t3)
    }

    /// For a single scope: read the document → if expired, set the score to delta; otherwise, add to the existing score.
    /// If expiresAt != nil, sets the (daily/weekly) field to the appropriate cutoff.
    private func upsertScoreTransaction(ref: DocumentReference,
                                        delta: Int,
                                        displayName: String,
                                        lastName: String,
                                        expiresAt: Timestamp?) async throws {
        try await db.runTransaction { txn, _ in
            let now = Date()

            var newScore = delta
            var shouldSetExpiry = expiresAt != nil   // if it's a new document, make sure to set it

            if let snap = try? txn.getDocument(ref), snap.exists {
                let data = snap.data() ?? [:]
                let oldScore = data["score"] as? Int ?? 0

                if let oldExp = data["expiresAt"] as? Timestamp, let _ = expiresAt {
                    // Daily/weekly: has it expired?
                    if oldExp.dateValue() > now {
                        // Not expired → add
                        newScore = oldScore + delta
                        shouldSetExpiry = false   // var olan geçerliyse tekrar yazmaya gerek yok
                    } else {
                        // Expired → reset and start with today's delta
                        newScore = delta
                        shouldSetExpiry = true
                    }
                } else {
                    // all-time or no expiry field → include
                    newScore = oldScore + delta
                }
            }

            var payload: [String: Any] = [
                "userId": ref.documentID,
                "displayName": displayName,
                "lastName": lastName,
                "score": newScore,
                "updatedAt": FieldValue.serverTimestamp()
            ]
            if let expiresAt, shouldSetExpiry {
                payload["expiresAt"] = expiresAt
            }

            txn.setData(payload, forDocument: ref, merge: true)
            return nil
        }
    }






}

@inline(__always)
func isExpired(_ ts: Timestamp?, now: Date = Date()) -> Bool {
    guard let ts else { return false }
    return ts.dateValue() <= now
}


extension FirestoreService {
    /// Top-N plus (if present) the user's own rank.
    /// Steps:
    /// 1) Fetch Top-N by score DESC from the scope collection (single-field sort → no composite index required).
    /// 2) If userId exists, read the user's document directly (O(1) document read).
    /// 3) meRank = count(score > myScore) + 1    (Aggregate COUNT; does not download documents, fast server-side)
    /// Note: If within Top-N, meRank can also be computed as index+1 within the top list.
    /// Delete expired documents in a single batch (keep it small so it doesn't block the UI).
    private func pruneExpired(in base: CollectionReference,
                              maxBatch: Int = 200) async throws {
        // All-time için expire yok → skip
        let snap = try await base
            .whereField("expiresAt", isLessThan: Timestamp(date: Date()))
            .limit(to: maxBatch)
            .getDocuments()

        guard !snap.isEmpty else { return }
        let batch = db.batch()
        for d in snap.documents { batch.deleteDocument(d.reference) }
        try await batch.commit()
    }

    func fetchLeaderboard(limit: Int,
                          scope: LeaderboardScope,
                          userId: String?) async throws -> LeaderboardResult {

        let base = db.collection("leaderboards")
            .document(scope.docId)
            .collection("entries")

        let now = Date()

        // 1) Top-N
        async let topSnapTask = base
            .order(by: "score", descending: true)
            .limit(to: limit)
            .getDocuments()

        // 2) My record (optional)
        async let meDocTask: DocumentSnapshot? = {
            guard let userId else { return nil }
            return try? await base.document(userId).getDocument()
        }()

        let topSnap = try await topSnapTask

        // Do not include expired (daily/weekly) entries in the list; optionally delete them
        var top: [LeaderboardEntry] = []
        var expiredRefs: [DocumentReference] = []

        for doc in topSnap.documents {
            let entry = try doc.data(as: LeaderboardEntry.self)
            if scope != .alltime, isExpired(entry.expiresAt, now: now) {
                expiredRefs.append(doc.reference)  // optional: delete later in a batch
                continue
            }
            top.append(entry)
        }

        if !expiredRefs.isEmpty {
            let batch = db.batch()
            expiredRefs.forEach { batch.deleteDocument($0) }
            try? await batch.commit()
        }

        // My entry and rank
        var me: LeaderboardEntry? = nil
        var meRank: Int? = nil

        if let meDoc = try await meDocTask, meDoc.exists {
            let myEntry = try meDoc.data(as: LeaderboardEntry.self)

            if scope != .alltime, isExpired(myEntry.expiresAt, now: now) {
                try? await meDoc.reference.delete() // remove if expired
            } else {
                me = myEntry
                if let idx = top.firstIndex(where: { $0.userId == myEntry.userId }) {
                    meRank = idx + 1
                } else {
                    let countSnap = try await base
                        .whereField("score", isGreaterThan: myEntry.score)
                        .count
                        .getAggregation(source: .server)
                    meRank = Int(truncating: countSnap.count) + 1
                }
            }
        }

        return LeaderboardResult(top: top, me: me, meRank: meRank)
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

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
        guard let userId = await UserSessionManager.shared.currentUser?.userId else {
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
        
        guard let userId = await UserSessionManager.shared.currentUser?.userId else {
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
        
        guard let userId = await UserSessionManager.shared.currentUser?.userId else {
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
                debugPrint("❌ Belge bulunamadı. Oluşturuluyor...")

                let s = UserSessionManager.shared.currentUser
                var created = UserInfoModel(
                    userId: s?.userId ?? userId,
                    email: s?.email ?? "",
                    name: s?.name ?? "",
                    lastname: s?.lastname ?? "",
                    dailyTarget: Constants.ScoreConstants.dailyTargetScore,
                    dailyScore: Constants.ScoreConstants.dailyLoginScoreBonus // 10
                )
                created.totalScore     = Constants.ScoreConstants.dailyLoginScoreBonus // 10
                created.dailyScoreDate = Date()

                self.createOrUpdateUserInfo(user: created) { success in
                    completion(success ? created : nil)  // ✅ nil değil, created döndür
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
            "dailyScoreDate" : Timestamp(date: userInfo.dailyScoreDate ?? Date())
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
    
    
    // file-scope
    private enum TZ {
        static let istanbul = TimeZone(identifier: "Europe/Istanbul")!
    }

    func nextDayCutoffDate(tz: TimeZone = TZ.istanbul) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        let startOfToday = cal.startOfDay(for: Date())
        return cal.date(byAdding: .day, value: 1, to: startOfToday)!
    }

    func nextWeekCutoffDate(tz: TimeZone = TZ.istanbul) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        cal.firstWeekday = 2
        let startOfThisWeek = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return cal.date(byAdding: .weekOfYear, value: 1, to: startOfThisWeek)!
    }

    
    
    
}

// MARK: - UPDATE (delete yok; expire olduysa resetle ve devam et)
extension FirestoreService {
    /// Puan güncelleme:
    /// - All-time: her zaman ekleme (expires yok).
    /// - Weekly/Daily: doküman varsa `expiresAt` kontrol edilir:
    ///     - expire OLMAMIŞSA: mevcut skora delta eklenir.
    ///     - expire OLMUŞSA: skor `delta` ile resetlenir ve yeni `expiresAt` yazılır.
    /// - Hiçbir yerde delete yok.
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

        // Üç scope'u paralelde yürüt (her biri transaction içinde reset/ekle kararını verir)
        async let a: Void = upsertScoreTransaction(
            ref: allTimeRef, delta: delta, displayName: name, lastName: lastName, expiresAt: nil
        )
        async let w: Void = upsertScoreTransaction(
            ref: weeklyRef,  delta: delta, displayName: name, lastName: lastName, expiresAt: weeklyExpTS
        )
        async let d: Void = upsertScoreTransaction(
            ref: dailyRef,   delta: delta, displayName: name, lastName: lastName, expiresAt: dailyExpTS
        )
        _ = try await (a, w, d)
    }

    /// Tek scope için transactional upsert:
    /// - (Daily/Weekly) expire geçmişse resetle, değilse ekle.
    /// - (All-time) her zaman ekle.
    /// - Burada asla delete yok.
    private func upsertScoreTransaction(ref: DocumentReference,
                                        delta: Int,
                                        displayName: String,
                                        lastName: String,
                                        expiresAt: Timestamp?) async throws {
        try await db.runTransaction { txn, _ in
            let now = Date()

            var newScore = delta
            var shouldSetExpiry = (expiresAt != nil) // yeni dokümanda veya expire resetinde yazılmalı

            if let snap = try? txn.getDocument(ref), snap.exists {
                let data = snap.data() ?? [:]
                let oldScore = data["score"] as? Int ?? 0

                if let oldExp = data["expiresAt"] as? Timestamp, expiresAt != nil {
                    // Daily/Weekly: expire kontrolü
                    if oldExp.dateValue() > now {
                        // Süresi geçmemiş → ekle
                        newScore = oldScore + delta
                        shouldSetExpiry = false // mevcut geçerliyse tekrar yazmaya gerek yok
                    } else {
                        // Süresi geçmiş → resetle (yeni dönem)
                        newScore = delta
                        shouldSetExpiry = true
                    }
                } else {
                    // All-time (veya expire alanı yok) → ekle
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

extension FirestoreService {

    // MARK: - Yardımcı: Süresi dolmuş mu?
    @inline(__always)
    func isExpired(_ ts: Timestamp?, now: Date = Date()) -> Bool {
        guard let ts else { return false }
        return ts.dateValue() <= now
    }

    // MARK: - Top-N + me/meRank (index gerektirmez)
    /// - alltime: expires filtre YOK
    /// - daily/weekly: expires filtreyi client’ta uygular; yeterli kayıt yoksa sayfalamaya devam eder
    func fetchLeaderboard(limit: Int,
                          scope: LeaderboardScope,
                          userId: String?) async throws -> LeaderboardResult {

        let base = db.collection("leaderboards")
            .document(scope.docId)
            .collection("entries")

        let now = Date()

        // 1) Top-N'i client-side filtreyle topla (index gerekmez)
        let top = try await collectTopNonExpired(
            from: base,
            scope: scope,
            limit: limit,
            now: now
        )

        // 2) Ben + Rank
        var me: LeaderboardEntry? = nil
        var meRank: Int? = nil

        if let uid = userId {
            if let meSnap = try? await base.document(uid).getDocument(), meSnap.exists {
                let myEntry = try meSnap.data(as: LeaderboardEntry.self)

                // daily/weekly’de süresi dolmuşsa göstermeyelim
                if scope != .alltime, isExpired(myEntry.expiresAt, now: now) {
                    me = nil
                    meRank = nil
                } else {
                    me = myEntry

                    // Top-N içindeyse index’den rank
                    if let idx = top.firstIndex(where: { $0.userId == uid }) {
                        meRank = idx + 1
                    } else {
                        // Değilse: sayfalayarak benden yüksek KAÇ adet var bul
                        meRank = try await computeRank(
                            for: myEntry,
                            in: base,
                            scope: scope,
                            now: now
                        )
                    }
                }
            }
        }

        return LeaderboardResult(top: top, me: me, meRank: meRank)
    }

    // MARK: - Score DESC sırayla sayfalayıp, süresi dolmayan ilk N kaydı topla
    private func collectTopNonExpired(from base: CollectionReference,
                                      scope: LeaderboardScope,
                                      limit: Int,
                                      now: Date,
                                      pageSize: Int = 50,
                                      hardCap: Int = 1000) async throws -> [LeaderboardEntry] {
        var result: [LeaderboardEntry] = []
        var lastScore: Int?
        var scanned = 0

        while result.count < limit {
            var q: Query = base.order(by: "score", descending: true).limit(to: pageSize)
            if let s = lastScore { q = q.start(after: [s]) }

            let snap = try await q.getDocuments()
            if snap.isEmpty { break }

            for doc in snap.documents {
                let e = try doc.data(as: LeaderboardEntry.self)
                scanned += 1

                // daily/weekly: expired'ı atla
                if scope != .alltime, isExpired(e.expiresAt, now: now) {
                    lastScore = e.score
                    continue
                }

                result.append(e)
                lastScore = e.score
                if result.count == limit { break }
                if scanned >= hardCap { break }
            }

            if result.count == limit || snap.documents.count < pageSize || scanned >= hardCap {
                break
            }
        }
        return result
    }

    // MARK: - Rank hesapla: score DESC sırada benden büyük olanları say
    private func computeRank(for me: LeaderboardEntry,
                             in base: CollectionReference,
                             scope: LeaderboardScope,
                             now: Date,
                             pageSize: Int = 100,
                             hardCap: Int = 5000) async throws -> Int {
        var greater = 0
        var lastScore: Int?
        var scanned = 0

        while true {
            var q: Query = base.order(by: "score", descending: true).limit(to: pageSize)
            if let s = lastScore { q = q.start(after: [s]) }

            let snap = try await q.getDocuments()
            if snap.isEmpty { break }

            for doc in snap.documents {
                let e = try doc.data(as: LeaderboardEntry.self)
                scanned += 1

                // daily/weekly: expired'ı sayma
                if scope != .alltime, isExpired(e.expiresAt, now: now) {
                    lastScore = e.score
                    continue
                }

                if e.score > me.score {
                    greater += 1
                    lastScore = e.score
                } else {
                    // sıralama kuralı gereği bundan sonrası <=
                    return greater + 1
                }

                if scanned >= hardCap { return greater + 1 } // güvenlik sınırı
            }

            if snap.documents.count < pageSize { break }
        }
        return greater + 1
    }
    
    

}

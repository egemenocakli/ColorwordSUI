//
//  UserInfoModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.03.2025.
//

import Foundation
import FirebaseFirestore

struct UserInfoModel: Identifiable, Decodable {
    var id: String = "userInfo"
    var userId: String
    var email: String
    var name: String
    var lastname: String
    var photo: String
    var totalScore: Int       // Kullanıcının genel skoru
    var dailyScore: Int       // Günlük skor
    var dailyTarget: Int      // Günlük hedef
    var dailyScoreDate: Date? // Sunucu zamanını Date olarak saklamak

    // MARK: - Yardımcı dönüştürücüler
    private static func intFrom(_ any: Any?) -> Int? {
        switch any {
        case let v as Int:      return v
        case let v as Int64:    return Int(v)
        case let v as UInt64:   return Int(v)
        case let v as Double:   return Int(v)
        case let v as Float:    return Int(v)
        case let v as NSNumber: return v.intValue
        case let v as String:   return Int(v)
        case is NSNull:         return nil
        default:                return nil
        }
    }

    private static func dateFrom(_ any: Any?) -> Date? {
        if let ts = any as? Timestamp { return ts.dateValue() }
        if let d  = any as? Date      { return d }
        if let s  = any as? String {
            let f = ISO8601DateFormatter()
            return f.date(from: s)
        }
        return nil
    }

    // MARK: - Firestore’a yaz
    func toDictionary() -> [String: Any] {
        [
            "userId": userId,
            "email": email,
            "name": name,
            "lastname": lastname,
            "photo": photo,
            "totalScore": totalScore,
            "dailyScore": dailyScore,
            "dailyTarget": dailyTarget,
            "dailyScoreDate": dailyScoreDate ?? FieldValue.serverTimestamp()
        ]
    }

    // MARK: - Firestore’dan oku (toleranslı)
    init?(dictionary: [String: Any], docId: String = "userInfo") {
        // userId eksikse docId'yi kullan; email ve name zorunlu
        let uid = (dictionary["userId"] as? String) ?? docId
        guard !uid.isEmpty,
              let email = dictionary["email"] as? String,
              let name  = dictionary["name"]  as? String
        else { return nil }

        self.id = docId
        self.userId = uid
        self.email = email
        self.name = name
        self.lastname = (dictionary["lastname"] as? String) ?? ""
        self.photo    = (dictionary["photo"]    as? String) ?? "empty"

        // Int64/NSNumber/Double/String hepsi kabul
        self.totalScore  = Self.intFrom(dictionary["totalScore"])  ?? 0
        self.dailyScore  = Self.intFrom(dictionary["dailyScore"])  ?? 0
        self.dailyTarget = Self.intFrom(dictionary["dailyTarget"]) ?? 100

        // Timestamp/Date/String hepsi kabul
        self.dailyScoreDate = Self.dateFrom(dictionary["dailyScoreDate"])
    }

    // MARK: - Convenience init (yeni kayıt oluşturma)
    init(userId: String,
         email: String,
         name: String,
         lastname: String,
         photo: String = "empty",
         totalScore: Int = 0,
         dailyTarget: Int,
         dailyScore: Int = 0,
         dailyScoreDate: Date? = nil,
         id: String = "userInfo") {

        self.id = id
        self.userId = userId
        self.email = email
        self.name = name
        self.lastname = lastname
        self.photo = photo
        self.totalScore = totalScore
        self.dailyTarget = dailyTarget
        self.dailyScore = dailyScore
        self.dailyScoreDate = dailyScoreDate
    }
}

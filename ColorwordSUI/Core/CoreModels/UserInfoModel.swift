//
//  UserInfoModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.03.2025.
//



import Foundation
import FirebaseFirestore

struct UserInfoModel: Identifiable {
    var id: String = "userInfo"
    var userId: String
    var email: String
    var name: String
    var lastname: String
    var photo: String
    var totalScore: Int
    var dailyScore: Int
    var dailyScoreDate: Date? // Sunucu zamanını Date olarak saklamak
    
    // Firestore’a yazarken sözlüğe dönüştürmek için
    func toDictionary() -> [String: Any] {
        return [
            "userId": userId,
            "email": email,
            "name": name,
            "lastname": lastname,
            "photo": photo,
            "totalScore": totalScore,
            "dailyScore": dailyScore,
            // Firestore’da tarih saklarken FieldValue.serverTimestamp() ya da Date -> Timestamp kullanabilirsin
            "dailyScoreDate": dailyScoreDate ?? FieldValue.serverTimestamp()
        ]
    }
    
    // Opsiyonel: Firestore’dan gelen veriyi modele dönüştürmek için init
    init?(dictionary: [String: Any], docId: String = "userInfo") {
        guard let userId = dictionary["userId"] as? String,
              let email = dictionary["email"] as? String,
              let name = dictionary["name"] as? String,
              let lastname = dictionary["lastname"] as? String,
              let photo = dictionary["photo"] as? String,
              let totalScore = dictionary["totalScore"] as? Int,
              let dailyScore = dictionary["dailyScore"] as? Int
        else {
            return nil
        }
        
        // dailyScoreDate bir Timestamp ise Date’e çevir
        var dateValue: Date? = nil
        if let timestamp = dictionary["dailyScoreDate"] as? Timestamp {
            dateValue = timestamp.dateValue()
        }
        
        self.id = docId
        self.userId = userId
        self.email = email
        self.name = name
        self.lastname = lastname
        self.photo = photo
        self.totalScore = totalScore
        self.dailyScore = dailyScore
        self.dailyScoreDate = dateValue
    }
    
    // Yeni model oluşturmak için bir convenience init
    init(userId: String,
         email: String,
         name: String,
         lastname: String,
         photo: String = "empty",
         totalScore: Int = 0,
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
        self.dailyScore = dailyScore
        self.dailyScoreDate = dailyScoreDate
    }
}

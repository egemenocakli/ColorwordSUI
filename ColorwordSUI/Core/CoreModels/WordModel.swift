//
//  WordModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 12.11.2024.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct Word {
    let wordId: String?
    var word: String?
    var translatedWords: [String]?
    var color: Color?
    var score: Int?
    var lastUpdateDate: Timestamp?
    var addDate: Timestamp?

    init(wordId: String? = nil, word: String? = nil, translatedWords: [String]? = nil, color: Color? = nil, score: Int? = 0, lastUpdateDate: Timestamp? = nil, addDate: Timestamp? = nil) {
        self.wordId = wordId
        self.word = word?.lowercased()
        self.translatedWords = translatedWords
        self.color = color
        self.score = score
        self.lastUpdateDate = lastUpdateDate
        self.addDate = addDate
    }
    
    init?(fromMap map: [String: Any]) {
        self.wordId = map["wordId"] as? String
        self.word = (map["word"] as? String)?.lowercased()
        self.translatedWords = Word.lowercaseFromList(map["translatedWords"] as? [String] ?? [])
        if let colorString = map["color"] as? String, colorString != "" {
            self.color = Color(hex: colorString)
        } else {
            self.color = nil
        }
        self.score = map["score"] as? Int
        self.lastUpdateDate = map["lastUpdateDate"] as? Timestamp
        self.addDate = map["addDate"] as? Timestamp
    }

    func toMap() -> [String: Any] {
        return [
            "wordId": wordId as Any,
            "word": word?.lowercased() as Any,
            "translatedWords": translatedWords as Any,
            "color": color?.toHex() as Any,
            "score": score as Any,
            "lastUpdateDate": lastUpdateDate as Any,
            "addDate": addDate as Any
        ]
    }

    static func lowercaseFromList(_ list: [String]) -> [String] {
        return list.map { $0.lowercased() }
    }
}



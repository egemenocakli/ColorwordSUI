//
//  Translate.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 1.05.2025.
//


struct TranslationResponse: Codable {
    let detectedLanguage: DetectedLanguage?
    let translations: [Translation]
}
struct DetectedLanguage: Codable {
    let language: String
    let score: Double
}

struct Translation: Codable {
    let text: String
    let to: String
}


struct TranslationRequest: Codable {
    let text: String
    let sourceLang: String
    let targetLang: String
    
    var path: String {
        return "/translator/text/v3.0/translate?from=\(sourceLang)&to=\(targetLang)"
    }
}

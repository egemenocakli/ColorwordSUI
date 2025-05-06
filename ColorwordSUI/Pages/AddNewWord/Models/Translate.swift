//
//  Translate.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 1.05.2025.
//


struct TranslationResponse: Codable {
    let translations: [Translation]
}

struct Translation: Codable {
    let text: String
    let to: String
}


struct TranslationRequest: Codable {
    let text: String
    let sourceLang: String
    let targetLang: String
    
    // Bu, URL path'ini oluşturmak için bir computed property olacak
    var path: String {
        return "/translator/text/v3.0/translate?from=\(sourceLang)&to=\(targetLang)"
    }
}

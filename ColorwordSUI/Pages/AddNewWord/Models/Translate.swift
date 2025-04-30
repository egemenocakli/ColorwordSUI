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

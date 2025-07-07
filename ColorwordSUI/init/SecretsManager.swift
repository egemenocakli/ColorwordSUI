//
//  SecretsManager.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 1.05.2025.
//

import SwiftUI


class SecretsManager {
    static let shared = SecretsManager()
    
    private var secrets: [String: Any] = [:]

    private init() {
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
            secrets = result
        }
    }

    func getValue(forKey key: String) -> String? {
        return secrets[key] as? String
    }
}

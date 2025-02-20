//
//  ServiceResponse.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 20.02.2025.
//

import Foundation


enum ServiceResponse<T> {
    case success(T)
    case failure(ServiceError)
}

enum ServiceError: Error {
    case networkError(String)       // İnternet bağlantısı hatası
    case authenticationError        // Kimlik doğrulama hatası
    case timeoutError               // Yanıt bekleme süresi doldu
    case unknownError               // Bilinmeyen hata
    case firebaseError(String)      // Firebase'den dönen özel hata
    case firestoreError(String)     // Firestore özel hata mesajları

    /// **Localized hata mesajlarını döndüren computed property**
    var localizedDescription: String {
        switch self {
        case .networkError(let message):
            return message.isEmpty ? Bundle.main.localizedString(forKey: "network_error", value: nil, table: nil) : message
        case .authenticationError:
            return Bundle.main.localizedString(forKey: "authentication_error", value: nil, table: nil)
        case .timeoutError:
            return Bundle.main.localizedString(forKey: "timeout_error", value: nil, table: nil)
        case .unknownError:
            return Bundle.main.localizedString(forKey: "unknown_error", value: nil, table: nil)
        case .firebaseError(let message):
            return message.isEmpty ? Bundle.main.localizedString(forKey: "firebase_error", value: nil, table: nil) : message
        case .firestoreError(let message):
            return message.isEmpty ? Bundle.main.localizedString(forKey: "firestore_error", value: nil, table: nil) : message
        }
    }
}

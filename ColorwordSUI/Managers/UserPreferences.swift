
//
//  UserPreferences.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 25.02.2025.
//

import SwiftUI
import KeychainAccess


class UserPreferences : ObservableObject {
    
    
    @AppStorage("email") var savedEmail: String = ""
    @AppStorage("theme") var savedTheme: String = ""
    @AppStorage("azureK") var savedAzureK: String = ""
//    @AppStorage("language") var savedLanguage: String = ""
    
}




class KeychainEncrpyter {
 
    let keychain = Keychain(service: "com.egemenocakli.ColorwordSUI")

    func savePassword(_ password: String) {
        do {
            try keychain.set(password, key: "userPassword")
            print("Şifre keychain'e kaydedildi.")
        } catch let error {
            print("Keychain'e kaydetme hatası: \(error)")
        }
    }

    func loadPassword() -> String? {
        do {
            let password = try keychain.get("userPassword")
            return password
        } catch let error {
            print("Keychain'den okuma hatası: \(error)")
            return nil
        }
    }
    
    func deletePassword() {
        do {
            try keychain.remove("userPassword")
            print("Şifre keychain'den silindi.")
        } catch let error {
            print("Keychain'den silme hatası: \(error)")
        }
    }
    
    func saveAzureK(_ userAzureK: String) {
        do {
            try keychain.set(userAzureK, key: "userAzureK")
            print("userAzureK keychain'e kaydedildi.")
        } catch let error {
            print("Keychain'e kaydetme hatası: \(error)")
        }
    }

    func loadAzureK() -> String? {
        do {
            if let azureK = try keychain.get("userAzureK") {
                return azureK
            } else {
                print("Keychain'den AzureK alınamadı.")
                return nil
            }
        } catch let error {
            print("Keychain'den okuma hatası: \(error)")
            return nil
        }
    }
    func deleteAzureK() {
        do {
            try keychain.remove("userAzureK")
            print("AzureK keychain'den silindi.")
        } catch let error {
            print("Keychain'den silme hatası: \(error)")
        }
    }
}

//  AddNewWordViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 29.04.2025.
//

import Foundation
import SwiftUI


class AddNewWordViewModel: ObservableObject {
    let keychainEncrypter = KeychainEncrpyter()

    @Published var enteredWord: String = ""
    @Published var translatedText: String = ""
    @Published var errorMessage: String?
    @Published var savedAzureK: String = ""
    
    private let addNewWordService = AddNewWordService()
    

    //TODO: geri dönüş error mesajları düzeltilecek oluyorsa translate edilcek yoksa ingilizce dönecek.
    //TODO: aşağıdaki uyarı düzeltilecek
    func loadAzureKFromKeychain()  {
        // Keychain'den AzureK'yi al
        if let loadedAzureK = keychainEncrypter.loadAzureK() {
            self.savedAzureK = loadedAzureK
            debugPrint("AzureK Keychain'den çekildi.")

        } else {
            // Eğer Keychain'den alınamıyorsa, Firestore'dan çek ve kaydet
            Task {
                do {
                    let azureKFromFirestore = try await addNewWordService.getAzureK() ?? ""
                    self.savedAzureK = azureKFromFirestore
                    // Keychain'e kaydet
                    keychainEncrypter.saveAzureK(savedAzureK)
                    debugPrint("AzureK Firestore'dan alındı ve Keychain'e kaydedildi: \(savedAzureK)")
                } catch {
                    debugPrint("AzureK alırken hata oluştu: \(error)")
                    self.errorMessage = "AzureK alınamadı"
                }
            }
            debugPrint("AzureK Keychain'den alınamadı.")
        }
    }
    
    func translate(text: String, from sourceLang: String, to targetLang: String) {
        
        let translationRequest = TranslationRequest(text: text, sourceLang: sourceLang, targetLang: targetLang)
        
        guard let url = URL(string: AzureAPIConstants.endPoint + translationRequest.path) else {
            errorMessage = "Geçersiz URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = RequestType.post.rawValue
        request.addValue(savedAzureK, forHTTPHeaderField: AzureAPIConstants.subscriptionKeyHTTPHeaderField)
        request.addValue(AzureAPIConstants.regionValue, forHTTPHeaderField: AzureAPIConstants.regionHTTPHeaderField)
        request.addValue(AzureAPIConstants.contentTypeValue, forHTTPHeaderField: AzureAPIConstants.contentTypeHTTPHeaderField)
        
        //Modeli JSON'a encode etme
        guard let requestData = try? JSONEncoder().encode([translationRequest]) else {
            errorMessage = "Veri kodlama hatası"
            return
        }
        request.httpBody = requestData
        
        //Veriyi göndermek için dataTask
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "İnternet bağlantısı hatası"
                }
                return
            }
            
            do {
                //Cevabı decode etme
                let decodedResponse = try JSONDecoder().decode([TranslationResponse].self, from: data)
                if let translatedText = decodedResponse.first?.translations.first?.text {
                    DispatchQueue.main.async {
                        self.translatedText = translatedText
                    }
                }else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Çeviri hatası"
                    }
                }
            }catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Veri Çözümleme Hatası"
                    debugPrint(String(data: data, encoding: .utf8) ?? "Veri yok")
                }
            }
            
        }
        task.resume()
    }
    
}

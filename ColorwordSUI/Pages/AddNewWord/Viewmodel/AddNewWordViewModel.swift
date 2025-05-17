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
    
    @Published var mainLanguage: Language?
    @Published var targetLanguage: Language?
    @Published var detectedLanguageId: String?
    @Published var detectedLanguage: String?
    
    @Published var targetLangList = Array(supportedLanguages.dropFirst())
    @Published var favoriteLanguageList: [Language] = []
    

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
    
    func translate(text: String, from sourceLang: Language, to targetLang: Language) async{
        
        let translationRequest = TranslationRequest(text: text, sourceLang: sourceLang.id, targetLang: targetLang.id)
        
        guard let url = URL(string: AzureAPIConstants.endPoint + translationRequest.path) else {
            errorMessage = "Geçersiz URL"
            return
        }
        do {
            try await self.getFavLanguages(for: sourceLang, for: targetLang, for: UserSessionManager.shared.userInfoModel)
        }catch{
            self.errorMessage = "Favori Dil Kaydedilemedi."
        }
        
        debugPrint("ana dil", mainLanguage?.id as Any )
        debugPrint("hedef dil",targetLanguage?.id as Any )
        
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

                

                let decodedResponse = try JSONDecoder().decode([TranslationResponse].self, from: data)
                if let detectLang = decodedResponse.first {
                    if let detected = detectLang.detectedLanguage {
                        
                        if let matchedLanguage = supportedLanguages.first(where: { $0.id == detected.language }) {
                            self.detectedLanguage = matchedLanguage.name
                            print("Bulunan dil: \(matchedLanguage.name)")
                        } else {
                            print("Dil bulunamadı.")
                        }
                        self.detectedLanguageId = detected.language
                    }
                }
                
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
    //Gönderilen dilleri source ve target olarak alıp dizi haline getirir
    func getFavLanguages (for sourceLang: Language, for targetLang: Language, for userInfo: UserInfoModel?) async throws {
        
        var favLangSet: Set<Language> = []
        
            favLangSet.insert(sourceLang)
            favLangSet.insert(targetLang)
        
        let favLangArray = Array(favLangSet)
        do {
            let wrapper = LanguageListWrapper(languages: favLangArray)
            try await saveFavLanguage(for: wrapper, for: userInfo)
            debugPrint("oldu")
            debugPrint(favLangArray)
        }catch {
            debugPrint("olmadı abi")

            self.errorMessage = error.localizedDescription
            debugPrint(error)
        }
    }
    
    //Kullanılacak yerden dil bilgisi alıncak 2 ayrı parametre olarak. sonra yuakrdan çağrılcak.
    func saveFavLanguage(for languages: LanguageListWrapper, for userInfo: UserInfoModel?) async throws {
//        var favLang: [Language] = []
//    
//        favLang = languages
        
        do {
            try await addNewWordService.saveFavLanguages(for: languages, for: userInfo)
            debugPrint("oldu2")
            

        }catch {
            debugPrint("olmadı2")
            self.errorMessage = error.localizedDescription
            debugPrint(error)
        }
    }
    
}



/*
 Lang picker da en çok kullanılan dilleri başa ekleyebilirim ingilizce türkçe almanca vs.
 favori diller eklenecek listenin başında yer alacak. maks 5 falan seçtirebilirim.
 kelime/cümle kaydı yapılacak.
 */

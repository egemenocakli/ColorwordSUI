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
    
    @Published var mainLangList: [Language] = Array(supportedLanguages)
    @Published var targetLangList = Array(supportedLanguages)
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
        
        await MainActor.run {
            self.mainLanguage = sourceLang
            self.targetLanguage = targetLang
        }

        do {

            try await self.getTranslatedLanguages(for: sourceLang, for: targetLang, for: UserSessionManager.shared.userInfoModel)
        }catch{
            self.errorMessage = "Favori Dil Kaydedilemedi."
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
    func getTranslatedLanguages (for sourceLang: Language, for targetLang: Language, for userInfo: UserInfoModel?) async throws {
        
        var favLangSet: Set<Language> = []
        
            favLangSet.insert(sourceLang)
            favLangSet.insert(targetLang)
        
        let favLangArray = Array(favLangSet)
        do {
            let wrapper = LanguageListWrapper(languages: favLangArray)
            try await saveFavLanguage(for: wrapper, for: userInfo)
            debugPrint("FavLanguage Kaydedildi1.")
            debugPrint(favLangArray)
        }catch {
            debugPrint("FavLanguage Kaydedilemedi1.")

            self.errorMessage = error.localizedDescription
            debugPrint(error)
        }
    }
    
    func saveFavLanguage(for languages: LanguageListWrapper, for userInfo: UserInfoModel?) async throws {

        
        do {
            try await addNewWordService.saveFavLanguages(for: languages, for: userInfo)
            debugPrint("FavLanguage Kaydedildi.2")
            

        }catch {
            debugPrint("FavLanguage Kaydedilemedi.2")
            self.errorMessage = error.localizedDescription
            debugPrint(error)
        }
    }
    func getFavLanguages() async throws {
        do {
            let favLanguages = try await addNewWordService.getFavLanguages(for: UserSessionManager.shared.userInfoModel)
            let detectLanguageId = ""

            let mainList = reorderLanguagesWithFavorites(
                favorites: favLanguages.languages,
                in: supportedLanguages,
                includeDetectLanguageAtTop: true,
                detectLanguageId: detectLanguageId
            )

            let targetList = reorderLanguagesWithFavorites(
                favorites: favLanguages.languages,
                in: supportedLanguages,
                includeDetectLanguageAtTop: false,
                detectLanguageId: detectLanguageId
            )

            DispatchQueue.main.async {
                self.mainLangList = mainList
                self.targetLangList = targetList
                self.favoriteLanguageList = favLanguages.languages
            }
        } catch {
            throw error
        }
    }

    //Dili algıla ve favori dilleri en üstte olacak şekilde sırala.
    func reorderLanguagesWithFavorites( favorites: [Language], in fullList: [Language], includeDetectLanguageAtTop: Bool = false, detectLanguageId: String = "" ) -> [Language] {
        var favoriteIDs = Set(favorites.map { $0.id })

        // detectLanguage'ı özel olarak başa alacağız, o yüzden diğer listelerden çıkar
        if includeDetectLanguageAtTop {
            favoriteIDs.remove(detectLanguageId)
        }

        let reorderedFavorites = favorites.filter { $0.id != detectLanguageId }
        let remainingLanguages = fullList.filter { !favoriteIDs.contains($0.id) && $0.id != detectLanguageId }

        var result = reorderedFavorites + remainingLanguages

        if includeDetectLanguageAtTop, let detectLang = fullList.first(where: { $0.id == detectLanguageId }) {
            result.insert(detectLang, at: 0)
        }

        return result
    }

    func addNewWord() async throws {
        
        guard !enteredWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !translatedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NSError(domain: "AddWordError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kelime veya çeviri boş olamaz."])
        }
        
        debugPrint(enteredWord)
        debugPrint(translatedText)
        
        var newWord = Word()
        newWord.word = enteredWord
        newWord.translatedWords = [translatedText]
        newWord.sourceLanguageId = mainLanguage?.id ?? ""
        newWord.translateLanguageId = targetLanguage?.id ?? ""
        do {
            try await addNewWordService.addNewWord(for: newWord, for: UserSessionManager.shared.userInfoModel)
            debugPrint("kelime ekleme başarılı")
        }catch{
            debugPrint("kelime ekleme başarısız")
            throw error
            
        }
        
    }
}


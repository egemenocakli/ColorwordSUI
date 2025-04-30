//
//  AddNewWordViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 29.04.2025.
//

import Foundation


class AddNewWordViewModel: ObservableObject {
    
    @Published var enteredWord: String = ""
    @Published var translatedText: String = ""
    @Published var errorMessage: String?
    
    let apiKey = SecretsManager.shared.getValue(forKey: "AZURE_TRANSLATE_KEY")
    let region = SecretsManager.shared.getValue(forKey: "AZURE_TRANSLATE_REGION")
    let endPoint = SecretsManager.shared.getValue(forKey: "AZURE_TRANSLATE_ENDPOINT")

    
    func translate(text: String, from sourceLang: String, to targetLang: String) {
        let path = "/translator/text/v3.0/translate?from=\(sourceLang)&to=\(targetLang)"
        guard let url = URL(string: endPoint! + path) else {
            errorMessage = "Geçersiz URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey!, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.addValue("westeurope", forHTTPHeaderField: "Ocp-Apim-Subscription-Region")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [[String: String]] = [["Text": text]]
        guard let requestData = try? JSONEncoder().encode(requestBody) else {
            errorMessage = "Veri kodlama hatası"
            return
        }
        request.httpBody = requestData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "İnternet bağlantısı hatası"
                }
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode([TranslationResponse].self, from: data)
                if let translatedText = decodedResponse.first?.translations.first?.text {
                    DispatchQueue.main.async {
                        self.translatedText = translatedText
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Çeviri hatası"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Veri çözümleme hatası"
                    print(String(data: data, encoding: .utf8) ?? "veri yok")

                }
            }
        }
        task.resume()
    }
}

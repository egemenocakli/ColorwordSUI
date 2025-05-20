//
//  AddNewWordService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.05.2025.
//

protocol AddNewWordServiceProtocol {
    func getAzureK() async throws -> String?
}

class AddNewWordService: AddNewWordServiceProtocol {
    
    private let firestoreService = FirestoreService()

    
    func getAzureK() async throws -> String? {
        do {
            let azureK = try await firestoreService.getAzureK()
            return azureK
        } catch {
            throw error
        }
    }
    
    func saveFavLanguages(for languages: LanguageListWrapper, for userInfo: UserInfoModel?) async throws {
        do{
            try await firestoreService.saveFavoriteLanguages(for: languages, for: userInfo)
        }catch{
            throw error
        }
    }
    
    func getFavLanguages(for userInfo: UserInfoModel?) async throws -> LanguageListWrapper {
        let favoriteLanguages: LanguageListWrapper
        do{
            favoriteLanguages = try await firestoreService.getFavoriteLanguages(for: userInfo)
            
        }catch{
            throw error
        }
        return favoriteLanguages
    }
}

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
    
    
}

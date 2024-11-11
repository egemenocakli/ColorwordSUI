//
//  HomeViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.11.2024.
//

import Foundation


class HomeViewModel: ObservableObject {
    @Published var wordList: [Word] = []
    private let firestoreService = FirestoreService()
    

    
    func getWordList() async {
        Task {
            do {
                let words = try await firestoreService.readWords()
                DispatchQueue.main.async {
                    self.wordList = words
                }
            } catch {
                print(error)
            }
        }
    }
}

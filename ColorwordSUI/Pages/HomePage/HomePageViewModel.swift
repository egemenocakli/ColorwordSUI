//
//  HomeViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.11.2024.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var wordList: [Word] = []
    @Published var wordBackgroundColor: String = "#000000"
    let homepageService = HomePageService()



    //TODO: öncesinde service eklenecek oradan buraya yönlenecek.
    
    func getWordList() async {
        Task {
            
            do {
                let words = try await homepageService.getWordList()
                    DispatchQueue.main.async {
                        self.wordList = words
                    }
                
            }catch {
                print(error)
            }
//            do {
//                let words = try await firestoreService.readWords()
//                DispatchQueue.main.async {
//                    self.wordList = words
//                }
//            } catch {
//                print(error)
//            }
        }
    }
}

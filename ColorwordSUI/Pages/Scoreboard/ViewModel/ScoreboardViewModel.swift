//
//  ScoreboardViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 25.07.2025.
//


import SwiftUI

class ScoreboardViewModel: ObservableObject {
    @Published var scores: [ScoreEntry] = []

    init() {
        fetchScores()
    }

    func fetchScores() {
        // Örnek veriler – Firebase veya local veritabanından alınabilir
        self.scores = [
            ScoreEntry(username: "Emre", score: 85, date: Date()),
            ScoreEntry(username: "Ayşe", score: 78, date: Date()),
            ScoreEntry(username: "Mert", score: 65, date: Date())
        ]
    }
}

struct ScoreEntry: Identifiable {
    let id = UUID()
    let username: String
    let score: Int
    let date: Date
}

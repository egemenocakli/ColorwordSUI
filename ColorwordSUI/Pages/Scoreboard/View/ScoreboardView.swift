//
//  ScoreboardView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 5.02.2025.
//

import SwiftUI

struct ScoreboardView: View {
    @StateObject var viewModel = ScoreboardViewModel()

    var body: some View {
        List {
            ForEach(viewModel.top.sorted(by: { $0.score > $1.score })) { entry in
                HStack {
                    Text(entry.displayName ?? entry.userId) // username yerine displayName
                        .font(.headline)
                    Spacer()
                    Text("\(entry.score)")
                        .font(.title3).bold()
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Leaderboard")
        .task { viewModel.load() } // ekrana gelince veriyi çek
    }
}

#Preview {
    ScoreboardView()
}

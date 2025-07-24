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
        VStack(alignment: .leading, spacing: 16) {

            List {
                ForEach(viewModel.scores.sorted(by: { $0.score > $1.score })) { entry in
                    HStack {
                        Text(entry.username)
                            .font(.headline)
                        Spacer()
                        Text("\(entry.score)")
                            .font(.title3).bold()
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Leaderboard").font(.headline)
    }
}

#Preview {
    ScoreboardView()
}

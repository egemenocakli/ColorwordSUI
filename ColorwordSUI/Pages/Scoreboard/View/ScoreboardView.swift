//
//  ScoreboardView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 5.02.2025.
//

import SwiftUI

struct ScoreboardView: View {
    @StateObject var scoreboardVM = ScoreboardViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Constants.ColorConstants.loginLightThemeBackgroundGradient
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    Text("leaderboard")
                        .foregroundStyle(Color(.textColorW))
                        .font(.title2).bold()
                        .padding(.leading)
                    Group {
                        
                        if scoreboardVM.top.isEmpty {
                            // Boş/Loading durumu
                            ProgressView("Loading…")
                                .task { scoreboardVM.load() } // görünür olur olmaz veriyi çek
                        } else {
                            
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(
                                        scoreboardVM.top.sorted(by: { $0.score > $1.score }),
                                        id: \.userId // <- LeaderboardEntry Identifiable değilse id ver
                                    ) { entry in
                                        Row(entry: entry)
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    ScoreboardView()
}


private struct Row: View {
    let entry: LeaderboardEntry

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                .fill(Color.wordListSelectorSharedCardColor)

            HStack {
                Text(entry.displayName ?? "anonymous")
                    .foregroundStyle(.textColorW)
                    .fontWeight(.bold)
                Spacer()
                Text("\(entry.score)")
                    .font(.headline).fontWeight(.heavy)
                    .foregroundStyle(.textColorW)
            }
            .padding()
        }
    }
}

/*
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
 */

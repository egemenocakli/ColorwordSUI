//
//  ScoreboardView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 5.02.2025.
//

import SwiftUI

struct ScoreboardView: View {
    @StateObject var scoreboardVM = ScoreboardViewModel()

    //TODO: localization eklenecek ve tema değişimi kontrol edilecek.
    var body: some View {
        NavigationStack {
            ZStack {
                Constants.ColorConstants.loginLightThemeBackgroundGradient
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading, spacing: 12){
                    Text("leaderboard")
                        .foregroundStyle(Color(.textColorW))
                        .font(.title2).bold()
                        .padding(.leading)
                    
                    if let msg = scoreboardVM.errorMessage {
                        Text(msg)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                    
                    if scoreboardVM.isLoading {
                        ProgressView("Loading…").padding(.top, 24)
                    }else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(scoreboardVM.top.enumerated()), id: \.element.userId) { idx, entry in
                                    Row(
                                        entry: entry,
                                        rank: idx + 1,
                                        highlightMe: entry.userId == scoreboardVM.me?.userId
                                    )
                                }
                            }
                            .padding(.vertical)
                            .padding(.bottom, 88)
                        }
                        .padding(.horizontal)
                    }
                    
                    if let me = scoreboardVM.me,
                       let meRank = scoreboardVM.meRank,
                       !scoreboardVM.isMeInTop
                    {
                        VStack{
                            Spacer()
                            MeBar(entry: me, rank: meRank)
                                .padding(.horizontal)
                                .padding(.bottom)
                                
                        }
                        
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: scoreboardVM.meRank)
                    }
                    

                }
            }
            .task {
                scoreboardVM.load()
            }
        }
    }
}

#Preview {
    ScoreboardView()
}


private struct Row: View {
    let entry: LeaderboardEntry
    let rank: Int
    let highlightMe: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                .fill(Color.wordListSelectorSharedCardColor.opacity(highlightMe ? 0.9 : 1.0))

            HStack(spacing: 12) {
                RankBadge(rank: rank)   // <-- rank burada

                Text(entry.displayName ?? "anonymous")
                    .foregroundStyle(Color(.textColorW))
                    .fontWeight(highlightMe ? .heavy : .bold)

                Spacer()

                Text(entry.score.formatted(.number.grouping(.automatic)))
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(Color(.textColorW))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
    }
}

private struct RankBadge: View {
    let rank: Int
    var body: some View {
        Text("#\(rank)")
            .font(.subheadline).bold()
            .foregroundStyle(Color(.textColorW))
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Color.white.opacity(0.12))
            .clipShape(Capsule())
    }
}


private struct MeBar: View {
    let entry: LeaderboardEntry
    let rank: Int

    var body: some View {
        HStack {
            RankBadge(rank: rank)
            Text(entry.displayName ?? "anonymous")
                .font(.headline).bold()
            Spacer()
            Text("\(entry.score)")
                .font(.title3).bold()
        }
        .foregroundStyle(Color(.textColorW))
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                .fill(Color.white.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                )
        )
        .shadow(radius: 6)
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

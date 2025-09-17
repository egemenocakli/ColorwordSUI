//
//  ScoreboardView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 5.02.2025.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject var scoreboardVM = LeaderboardViewModel()
    @State private var selectedType: LeaderboardType = .daily

    //TODO: localization eklenecek ve tema değişimi kontrol edilecek.
    //Liste dolunca meBar ile iç içe geçecek mi? kontrol et
    var body: some View {
        NavigationStack {
            ZStack (alignment: .topLeading){
                Constants.ColorConstants.loginLightThemeBackgroundGradient
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .center, spacing: 12){
                    Text("leaderboard")
                        .foregroundStyle(Color(.textColorW))
                        .font(.title2).bold()
                        .padding(.leading)
                    
                    
                    //LeaderboardType
                    ZStack {
                        RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                            .fill(Color(.backgroundColor2).opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )

                        Picker("Scope", selection: $selectedType) {
                            ForEach(LeaderboardType.allCases) { t in
                                Text(t.title).tag(t)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(Constants.ColorConstants.whiteColor)
                        .padding(6)
                    }
                    .frame(height: 44)
                    .padding(.horizontal)


                    if let msg = scoreboardVM.errorMessage {
                        Text(msg)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                    if scoreboardVM.isLoading {
                        ProgressView("Loading…")
                            .progressViewStyle(CircularProgressViewStyle(tint: Constants.ColorConstants.whiteColor))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .allowsHitTesting(false)
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
                            //.padding(.bottom, 88)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .topLeading)
                    }
                   
                        
                    
                    

                    


                }
                .safeAreaInset(edge: .bottom) {
                    if let me = scoreboardVM.me,
                       let meRank = scoreboardVM.meRank,
                       !scoreboardVM.isMeInTop {
                        MeBar(entry: me, rank: meRank)
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                }
                
            }
            .onChange(of: selectedType) { _, newValue in
                            scoreboardVM.load(scope: newValue.dbScope)
            }
            .task {
                scoreboardVM.load(scope: selectedType.dbScope)
                    
            }
            
        }
        
    }
}

#Preview {
    LeaderboardView()
}


private struct Row: View {
    let entry: LeaderboardEntry
    let rank: Int
    let highlightMe: Bool

    var body: some View {
        ZStack {
            
            /*
            RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                //.fill(Color.wordListSelectorSharedCardColor.opacity(highlightMe ? 0.9 : 1.0))
                .fill(highlightMe ? Color.blue.opacity(0.3) : Color.wordListSelectorSharedCardColor)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
            */

            let base = highlightMe ? Color.blue.opacity(0.30)
                                    : Color.wordListSelectorSharedCardColor
            
            RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                .fill(podiumFillStyle(rank: rank, base: base))
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                        .strokeBorder(Color.white.opacity(0.20), lineWidth: rank <= 3 ? 1.5 : 1)
                )
            
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
                .fill(Color.wordListSelectorSharedCardColor)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                        .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
                )
            
            /*
            RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                .fill(Color(.backgroundColor2).opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )
            */
        )
        .shadow(radius: 6)
    }
}

func podiumFillStyle(rank: Int, base: Color) -> AnyShapeStyle {
    switch rank {
    case 1:
        return AnyShapeStyle(
            LinearGradient(
                colors: [Color.yellow.opacity(0.45), Color.orange.opacity(0.35)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
    case 2:
        return AnyShapeStyle(
            LinearGradient(
                colors: [Color.gray.opacity(0.35), Color.white.opacity(0.40)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
    case 3:
        return AnyShapeStyle(
            LinearGradient(
                colors: [Color.brown.opacity(0.40), Color.orange.opacity(0.25)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
    default:
        return AnyShapeStyle(base)
    }
}

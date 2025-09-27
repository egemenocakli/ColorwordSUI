//
//  ScoreboardView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 5.02.2025.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject var leaderboardVM = LeaderboardViewModel()
    @State private var selectedType: LeaderboardType = .daily
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    
    //Liste dolunca meBar ile iç içe geçecek mi? kontrol et
    
    var body: some View {
        NavigationStack {
            ZStack (alignment: .topLeading){
                Constants.ColorConstants.loginLightThemeBackgroundGradient
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .center, spacing: 12){
                    
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
                                Text(t.titleKey).tag(t)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(Constants.ColorConstants.whiteColor)
                        .padding(6)
                    }
                    .frame(height: 44)
                    .padding(.horizontal)


                    if let msg = leaderboardVM.errorMessage {
                        Text(msg)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                    if leaderboardVM.isLoading {
                        ProgressView("loading")
                            .progressViewStyle(CircularProgressViewStyle(tint: Constants.ColorConstants.whiteColor))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .allowsHitTesting(false)
                    }else {
                        
                        LeaderboardUserRow(viewModel: leaderboardVM)
                    }

                }
                .safeAreaInset(edge: .bottom) {
                    if let me = leaderboardVM.me,
                       let meRank = leaderboardVM.meRank,
                       !leaderboardVM.isMeInTop {
                        MeBar(entry: me, rank: meRank)
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                }
                
            }
            .environment(\.locale, .init(identifier: languageManager.currentLanguage))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("leaderboard")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.textColorW))

                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onChange(of: selectedType) { _, newValue in
                            leaderboardVM.load(scope: newValue.dbScope)
            }
            .task {
                leaderboardVM.load(scope: selectedType.dbScope)
                    
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


            let base = highlightMe ? Color.blue.opacity(0.30)
                                    : Color.wordListSelectorSharedCardColor
            
            RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                .fill(podiumFillStyle(rank: rank, base: base))
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.xxSmall)
                        .strokeBorder(Color.white.opacity(0.30), lineWidth: rank <= 3 ? 2 : 1)
                )
            
            HStack(spacing: 12) {
                RankBadge(rank: rank)

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

fileprivate func LeaderboardUserRow(viewModel: LeaderboardViewModel) -> some View {
    return ScrollView {
        LazyVStack(spacing: 12) {
            ForEach(Array(viewModel.top.enumerated()), id: \.element.userId) { idx, entry in
                Row(
                    entry: entry,
                    rank: idx + 1,
                    highlightMe: entry.userId == viewModel.me?.userId
                )
            }
        }
        .padding(.vertical)
    }
    .padding(.horizontal)
    .padding(.top, 8)
    .frame(maxWidth: .infinity,
           maxHeight: .infinity,
           alignment: .topLeading)
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
            
        )
        .shadow(radius: 6)
    }
}

func podiumFillStyle(rank: Int, base: Color) -> AnyShapeStyle {
    switch rank {
    case 1:
        return AnyShapeStyle(
            Constants.ColorConstants.goldCardColor
        )
    case 2:
        return AnyShapeStyle(
            Constants.ColorConstants.silverCardColor
        )
    case 3:
        return AnyShapeStyle(
            Constants.ColorConstants.bronzeCardColor
        )
    default:
        return AnyShapeStyle(base)
    }
}

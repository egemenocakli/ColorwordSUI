//
//  ScoreboardViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 25.07.2025.
//


import SwiftUI

final class ScoreboardViewModel: ObservableObject {
    @Published var top: [LeaderboardEntry] = []
    @Published var me: LeaderboardEntry?

    private let scoreboardService: ScoreboardServiceInterface = ScoreboardService()

    func load(scope: LeaderboardScope = .alltime, limit: Int = 10) {
        Task {
            do {
                let result = try await scoreboardService.fetchLeaderboard(
                    limit: limit,
                    scope: scope,
                    includeCurrentUser: true
                )
                await MainActor.run {
                    self.top = result.top
                    self.me  = result.me
                }
            } catch {
                print("Leaderboard yüklenemedi:", error)
            }
        }
    }
}


/*
 
 import SwiftUI

 final class ScoreboardViewModel: ObservableObject {
     @Published var top: [LeaderboardEntry] = []
     @Published var me: LeaderboardEntry?

     private let scoreboardService: ScoreboardServiceInterface = ScoreboardService()

     func load(scope: LeaderboardScope = .alltime, limit: Int = 10) {
         Task {
             do {
                 let result = try await scoreboardService.fetchLeaderboard(
                     limit: limit,
                     scope: scope,
                     includeCurrentUser: true
                 )
                 await MainActor.run {
                     self.top = result.top
                     self.me  = result.me
                 }
             } catch {
                 print("Leaderboard yüklenemedi:", error)
             }
         }
     }
 }
 */

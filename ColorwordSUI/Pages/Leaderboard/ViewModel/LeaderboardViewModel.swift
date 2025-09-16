//
//  ScoreboardViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 25.07.2025.
//


import SwiftUI

final class LeaderboardViewModel: ObservableObject {
    @Published var top: [LeaderboardEntry] = []
    @Published var me: LeaderboardEntry?
    @Published var meRank: Int?
    @Published var isMeInTop = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = FirestoreService()

    func load(limit: Int = 5, scope: LeaderboardScope = .alltime, userId: String? = UserSessionManager.shared.userInfoModel?.userId) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let res = try await service.fetchLeaderboard(limit: limit, scope: scope, userId: userId)
                await MainActor.run {
                    self.top = res.top
                    self.me = res.me
                    self.meRank = res.meRank
                    self.isMeInTop = (res.meRank ?? Int.max) <= limit
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
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

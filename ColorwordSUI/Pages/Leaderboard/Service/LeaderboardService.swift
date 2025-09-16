//
//  ScoreboardService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 9.09.2025.
//

import Foundation

protocol LeaderboardServiceInterface {
    func fetchLeaderboard(
        limit: Int,
        scope: LeaderboardScope,
        includeCurrentUser: Bool
    ) async throws -> LeaderboardResult
}

final class LeaderboardService: LeaderboardServiceInterface {
    private let firestoreService = FirestoreService()

    func fetchLeaderboard(
        limit: Int = 5,
        scope: LeaderboardScope = .alltime,
        includeCurrentUser: Bool = true
    ) async throws -> LeaderboardResult {

        let uid = includeCurrentUser
        ? UserSessionManager.shared.userInfoModel?.userId
        : nil

        return try await firestoreService.fetchLeaderboard(limit: limit, scope: .alltime, userId: uid)
    }
}

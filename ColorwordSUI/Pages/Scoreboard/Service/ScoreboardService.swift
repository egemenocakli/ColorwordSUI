//
//  ScoreboardService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 9.09.2025.
//

import Foundation

protocol ScoreboardServiceInterface {
    func fetchLeaderboard(
        limit: Int,
        scope: LeaderboardScope,
        includeCurrentUser: Bool
    ) async throws -> LeaderboardResult
}

final class ScoreboardService: ScoreboardServiceInterface {
    private let firestoreService = FirestoreService()

    func fetchLeaderboard(
        limit: Int = 10,
        scope: LeaderboardScope = .alltime,
        includeCurrentUser: Bool = true
    ) async throws -> LeaderboardResult {

        let uid = includeCurrentUser
        ? UserSessionManager.shared.userInfoModel?.userId
        : nil

        return try await firestoreService.getLeaderboardScores(
            limit: limit,
            alsoInclude: uid,
            scope: scope
        )
    }
}

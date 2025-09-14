//
//  LeaderboardEnry.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 9.09.2025.
//

import FirebaseFirestore


enum LeaderboardScope: String {
    case alltime = "global-alltime"
    case weekly  = "global-weekly"
    case daily   = "global-daily"
}

struct LeaderboardEntry: Codable, Identifiable {
    var id: String { userId }
    let userId: String
    let displayName: String?
    let lastName: String?
    let score: Int
    let updatedAt: Date?
}

struct LeaderboardResult {
    let top: [LeaderboardEntry]
    let me: LeaderboardEntry?
}

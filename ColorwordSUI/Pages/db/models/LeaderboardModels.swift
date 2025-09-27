//
//  LeaderboardEnry.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 9.09.2025.
//

import FirebaseFirestore


enum LeaderboardScope: String {
    case alltime, weekly, daily
    var docId: String { "global-\(rawValue)" }
}

struct LeaderboardEntry: Codable, Identifiable {
    var id: String { userId }
    let userId: String
    let displayName: String?
    let score: Int
    let updatedAt: Timestamp?
    let expiresAt: Timestamp?
}

struct LeaderboardResult {
    let top: [LeaderboardEntry]   // Sadece Top-N
    let me: LeaderboardEntry?     // Kullanıcı (varsa)
    let meRank: Int?              // Sırası (varsa)
}

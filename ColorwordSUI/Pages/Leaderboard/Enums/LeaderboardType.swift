//
//  LeaderboardScope.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 16.09.2025.
//

enum LeaderboardType: String, CaseIterable, Identifiable {
    case daily, weekly, alltime
    var id: String { rawValue }
    var title: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .alltime: return "All-Time"
        }
    }
}

extension LeaderboardType {
    var dbScope: LeaderboardScope {
        switch self {
        case .daily:   return .daily
        case .weekly:  return .weekly
        case .alltime: return .alltime
        }
    }
}



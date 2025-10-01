//
//  LeaderboardScope.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 16.09.2025.
//

import SwiftUICore

enum LeaderboardType: String, CaseIterable, Identifiable {
    case daily, weekly, alltime
    var id: String { rawValue }
    
    var titleKey: LocalizedStringKey {
        switch self {
        case .daily: return "leaderboard_daily"
        case .weekly: return "leaderboard_weekly"
        case .alltime: return "leaderboard_all_time"
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



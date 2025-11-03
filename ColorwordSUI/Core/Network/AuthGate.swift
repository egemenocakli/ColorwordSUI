//
//  AuthGate.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 19.10.2025.
//

import SwiftUI

struct AuthGate: View {
    @StateObject private var session = UserSessionManager.shared

    var body: some View {
        Group {
            if session.isRestoring {
                ZStack {
                    ProgressView("Loading…").progressViewStyle(.circular)
                }
            } else if session.currentUser != nil {
                HomeView() // mevcut ana ekranın
            } else {
                LoginView()
            }
        }
    }
}

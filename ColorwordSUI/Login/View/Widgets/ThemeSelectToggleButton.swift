//
//  ThemeSelectToggleButton.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 5.11.2024.
//

import SwiftUI


//TODO: Sayısal değerler costants tan çekilecek.
struct ThemeSelectToggleButton: View {
    @Binding var isDarkMode: Bool
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: Constants.SizeRadiusConstants.large)
                .fill(isDarkMode ? Color(.gray).opacity(0.1) :   .gray.opacity(0.1))
                .frame(width: 80, height: 40)
                .overlay(
                    HStack {
                        if isDarkMode {
                            Spacer()
                        }
                        
                        ZStack {
                            Image(systemName: isDarkMode ? "sun.max" :   "moon.stars.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding()
                                .foregroundStyle(isDarkMode ? .yellow : .black)
                                .transition(.scale)
                                .animation(.easeInOut, value: isDarkMode)
                        }
                        
                        if !isDarkMode {
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 5)
                )
                .onTapGesture {
                    withAnimation {
                        isDarkMode.toggle()
                    }
                }
        }
    }
}

//#Preview {
//    @Previewable @EnvironmentObject var themeManager: ThemeManager
//
//    ThemeSelectToggleButton(isDarkMode: Binding(
//        get: { themeManager.selectedTheme == Constants.AppTheme.dark_mode.rawValue },
//        set: { _ in themeManager.toggleTheme() }))
//}

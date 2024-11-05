//
//  ThemeManager.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 5.11.2024.
//

import Foundation
import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: String = Constants.AppTheme.light_mode.rawValue {
        didSet {
            updateColorScheme()
        }
    }
    
    @Published var colorScheme: ColorScheme = .light
    
    init() {
        updateColorScheme()
    }
    
    private func updateColorScheme() {
        colorScheme = selectedTheme == Constants.AppTheme.dark_mode.rawValue ? .dark : .light
    }
    
    func toggleTheme() {
        selectedTheme = selectedTheme == Constants.AppTheme.dark_mode.rawValue ? Constants.AppTheme.light_mode.rawValue : Constants.AppTheme.dark_mode.rawValue
    }
    

}

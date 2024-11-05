import Foundation
import SwiftUI

//TODO: Eğer kullanıcı uygulamayı ilk defa açıyorsa cihaz temasını uygulamaya aktarsın.
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
    
    func setSystemTheme(_ systemTheme: ColorScheme) {
        print("Sistem default theme: \(systemTheme == .dark ? "Karanlık Mod" : "Aydınlık Mod")")
    }
}



//
//  UserPreferences.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 25.02.2025.
//

import SwiftUI

class UserPreferences : ObservableObject {
    
    
    @AppStorage("email") var savedEmail: String = ""
    @AppStorage("password") var savedPassword: String = ""
    @AppStorage("theme") var savedTheme: String = "light"
    
}


//keychainacces eklendi. password için kullanılacak.

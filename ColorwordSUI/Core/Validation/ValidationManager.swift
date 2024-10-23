//
//  LoginValidation.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 24.10.2024.
//

import Foundation
import SwiftUI

// Doğrulama hataları için enum
enum ValidationError {
    case emptyFields
    case shortPassword
    case invalidEmail
}

// ValidationManager: Doğrulamayı yöneten sınıf
class ValidationManager {
    // Giriş doğrulamasını kontrol eder
    func validate(email: String, password: String) -> ValidationError? {
        if email.isEmpty || password.isEmpty {
            return .emptyFields
        } else if password.count < 6 {
            return .shortPassword
        } else if !isValidEmail(email) {
            return .invalidEmail
        }
        return nil
    }
    
    // Email formatının doğruluğunu kontrol eder
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}


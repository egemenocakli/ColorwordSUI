//
//  LimitTextEditor.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 29.04.2025.
//

import SwiftUI

extension View {
    func limitTextEditorCharacters(_ text: Binding<String>, limit: Int) -> some View {
        self.onChange(of: text.wrappedValue) {
            if text.wrappedValue.count > limit {
                text.wrappedValue = String(text.wrappedValue.prefix(limit))
            }
        }
    }
}

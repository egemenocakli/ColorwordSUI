//
//  ButtonWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 4.10.2025.
//

import SwiftUI

struct ButtonWidget: View {
    // Localization uyumlu başlık
    let titleKey: LocalizedStringKey
    // Görünüm ayarları
    var width: CGFloat? = nil
    var height: CGFloat = 50
    var backgroundColor: Color = .blue
    var foregroundColor: Color = .white
    var cornerRadius: CGFloat = 14
    var font: Font? = .system(.body)
    var fontWeight: Font.Weight? = nil
    var showBorder: Bool = true
    // Shadow (opsiyonel)
    var shadowColor: Color = .clear
    var shadowRadius: CGFloat = 0
    var shadowX: CGFloat = 0
    var shadowY: CGFloat = 0

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(titleKey) // "login_button" gibi localization key ver
                .font(font)
                .foregroundStyle(foregroundColor)
                .frame(width: width, height: height)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(backgroundColor)
                )
                .overlay {
                    if showBorder {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.black.opacity(0.12), lineWidth: 1)
                    }
                }
                .shadow(color: shadowColor, radius: shadowRadius, x: shadowX, y: shadowY)
        }
        .buttonStyle(.plain)       // kendi stilimiz bozulmasın
        .contentShape(Rectangle()) // dokunma alanı net olsun
    }
}

//
//  CategoryItem.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 4.02.2025.
//

import Foundation
import SwiftUICore


struct CategoryItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView
}

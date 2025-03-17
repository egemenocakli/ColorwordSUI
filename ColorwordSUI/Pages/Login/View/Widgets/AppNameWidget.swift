//
//  AppNameWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 18.10.2024.
//

import Foundation
import SwiftUI

struct AppNameWidget: View {
    let geometry: GeometryProxy

    var body: some View {
        appNameTextWidget(geometry: geometry)
    }
    
    func appNameTextWidget(geometry: GeometryProxy) -> some View {
        Text(Constants.appName)
            .frame(width: UIScreen.main.bounds.width, height: Constants.PaddingSizeConstants.xlSize, alignment: .center)
            .font(.system(size: Constants.FontSizeConstants.hugeSize))
            .frame(height: geometry.size.height * 0.3)
            //.foregroundStyle(Constants.ColorConstants.whiteFont)
            .foregroundStyle(Color.appNameColor)
    }
}

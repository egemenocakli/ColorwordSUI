//
//  ProgressWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 6.02.2025.
//


import SwiftUI


//TODO: Ölçü ve renkler constantstan alınacak. language eklenecek
//Yeni bir alan açılacak. günlük kazanılmış puanları tutacak. günlük?
struct DailyProgressView: View {
    var progress: Double
    let totalPoints: Double = 100

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Daily Progress")
                    .font(.headline)
                    .foregroundColor(.white)

                ZStack(alignment: .leading) {
                    // Arka Plan Çubuğu
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: 300, height: 20)
                        .foregroundColor(Color.black.opacity(0.3))
                    
                    // İlerleme Çubuğu: progress değeri değiştiğinde animasyonla genişliğini günceller.
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: CGFloat(progress / totalPoints) * 300, height: 20)
                        .foregroundColor(.green)
                        .animation(.easeInOut(duration: 1), value: progress)
                }
                
                Text("\(Int(progress))/\(Int(totalPoints))")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
        .frame(height: 100)
    }
}

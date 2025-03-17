//
//  ProgressWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 6.02.2025.
//


import SwiftUI


//TODO: Ölçü ve renkler constantstan alınacak.
//Yeni bir alan açılacak. günlük kazanılmış puanları tutacak. günlük?
struct DailyProgressView: View {
    @State private var progress: Double = 50
    let totalPoints: Double = 100

    var body: some View {
        VStack {
            Text("Daily Progress")
                .font(.headline)
                .foregroundColor(.white)

            ZStack(alignment: .leading) {
                // Arka Plan Çubuğu
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 300, height: 20) // Buradan çizginin yüksekliğini artırabilirsin
                    .foregroundColor(Color.gray.opacity(0.3))

                // İlerleme Çubuğu
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: CGFloat(progress / totalPoints) * 300, height: 20)
                    .foregroundColor(.green)
            }
            .padding()

            Text("\(Int(progress))/\(Int(totalPoints))")
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    DailyProgressView()
}

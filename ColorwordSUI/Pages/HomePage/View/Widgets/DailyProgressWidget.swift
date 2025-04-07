//
//  ProgressWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 6.02.2025.
//


import SwiftUI


//TODO: Ölçü ve renkler constantstan alınacak. language eklenecek
struct DailyProgressView: View {
    var progress: Double
    var dailyTarget: Double
    @State var showPicker = false
    @StateObject private var homeVM = HomeViewModel.shared

    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Daily Progress")
                    .font(.headline)
                    .foregroundColor(.white)
                ZStack{
                    ZStack(alignment: .leading) {
                        // Arka Plan Çubuğu
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: 300, height: 20)
                            .foregroundColor(Color.black.opacity(0.3))
                        
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: min(CGFloat(progress / dailyTarget) * 300, 300), height: 20)
                            .foregroundColor(progress <= 99 ? .green : .yellow.opacity(0.9))
                            .animation(.easeInOut(duration: 1), value: progress)
                            .shadow(color: progress >= dailyTarget ? Color.yellow : Color.clear,
                                    radius: progress >= dailyTarget ? 10 : 0,
                                    x: 0,
                                    y: 0)
                        
                        
                    }
                    Text("\(Int(progress))/\(Int(dailyTarget))")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)

                }
                
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
 
        }
        .onTapGesture {
            showPicker.toggle()
        }
        .sheet(isPresented: $showPicker, content: {
            ContentView(showPicker: $showPicker, homeVM: homeVM)
                .presentationDetents([.fraction(0.1)])
                .presentationCornerRadius(20)

        })
        .frame(height: 80)
        
    }
    
    struct ContentView: View {
        @State private var selectedValue = 100
        @Binding var showPicker: Bool
        @ObservedObject var homeVM: HomeViewModel

        var body: some View {
            HStack{
                Text("Daily Target")
                    .font(.headline)
                    .padding(.all, 20)
                Picker("Daily Target", selection: $selectedValue) {
                    
                    
                    // 100’den 500’e kadar 50’şer artan bir dizi oluşturuyoruz
                    ForEach(Array(stride(from: 100, through: 500, by: 50)), id: \.self) { value in
                        Text("\(value)")
                            .tag(value)
                    }
                }
                .pickerStyle(.wheel) // Teker (wheel) stilinde gösterim
                .frame(width: 100, height: 100)
//                Button {
//                    homeVM.updateDailyTarget(dailyTarget: selectedValue)
//                    showPicker.toggle()
//                }label: {
//                    Image(systemName: "checkmark")
//                }.frame(width: 80, height: 80)
//                
                Button(action: {
                    homeVM.updateDailyTarget(dailyTarget: selectedValue)
                    showPicker.toggle()
                }) {
                    Image(systemName: "checkmark.rectangle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                        .shadow(color: .green.opacity(0.6), radius: 5, x: 0, y: 3)
                }
                .padding(.leading, 20)
                .buttonStyle(PlainButtonStyle())
            }
        }
        
     
    }
}

//#Preview {
//    DailyProgressView(progress: 120)
//}

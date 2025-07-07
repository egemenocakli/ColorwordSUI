//
//  ProgressWidget.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 6.02.2025.
//


import SwiftUI


struct DailyProgressView: View {
    var progress: Double
    var dailyTarget: Double
    @State var showPicker = false
    @StateObject private var homeVM = HomeViewModel.shared
    @EnvironmentObject var languageManager: LanguageManager

    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("daily_target")
                    .font(.headline)
                    .foregroundColor(Constants.ColorConstants.whiteTextColor)
                ZStack{
                    ZStack(alignment: .leading) {
                        // Background bar
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
                        .foregroundColor(Constants.ColorConstants.whiteTextColor)

                }
                
                
            }
            .environment(\.locale, .init(identifier: languageManager.currentLanguage))
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
 
        }
        .onTapGesture {
            showPicker.toggle()
        }
        .sheet(isPresented: $showPicker, content: {
            BottomSheet(showPicker: $showPicker, homeVM: homeVM)
                .presentationDetents([.fraction(0.1)])
                .presentationCornerRadius(Constants.SizeRadiusConstants.large)

        })
        
        .frame(height: 80)
        
    }
    //Daily target score picker. Bottom sheet
    struct BottomSheet: View {
        @State private var selectedValue = 100
        @Binding var showPicker: Bool
        @ObservedObject var homeVM: HomeViewModel
        @EnvironmentObject var languageManager: LanguageManager


        var body: some View {
            HStack{
                Text("daily_target")
                    .font(.headline)
                    .foregroundStyle(.blacktoWhite)
                    .padding(.all, 20)
                Picker("daily_target", selection: $selectedValue) {
                    
                    
                    ForEach(Array(stride(from: 100, through: 1000, by: 50)), id: \.self) { value in
                        Text("\(value)")
                            .tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100, height: 100)

                Button(action: {
                    homeVM.updateDailyTarget(dailyTarget: selectedValue)
                    showPicker.toggle()
                }) {
                    Image(systemName: Constants.IconTextConstants.okButtonRectangle)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue.opacity(0.6))
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.leading, 20)
                .buttonStyle(PlainButtonStyle())
            }
            .environment(\.locale, .init(identifier: languageManager.currentLanguage))

        }
        
     
    }
}

//#Preview {
//    DailyProgressView(progress: 120)
//}

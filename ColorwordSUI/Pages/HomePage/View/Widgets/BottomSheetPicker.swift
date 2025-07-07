//
//  BottomSheetPicker.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 8.05.2025.
//

import SwiftUI

//Generic Type
struct BottomSheetPicker<VM: ObservableObject>: View {
    @State private var selectedValue = 100
    @Binding var showPicker: Bool
//    @ObservedObject var homeVM: HomeViewModel
    @ObservedObject var viewModel: VM
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
//                homeVM.updateDailyTarget(dailyTarget: selectedValue)
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
//
//import SwiftUI
//
////Generic Type
//struct BottomSheetPicker<VM: ObservableObject>: View {
//    @State private var selectedValue = 100
//    @Binding var showPicker: Bool
////    @ObservedObject var homeVM: HomeViewModel
//    @ObservedObject var viewModel: VM
//    @EnvironmentObject var languageManager: LanguageManager
//    
//    
//    var body: some View {
//        HStack{
//            Text("daily_target")
//                .font(.headline)
//                .foregroundStyle(.blacktoWhite)
//                .padding(.all, 20)
//            Picker("daily_target", selection: $selectedValue) {
//                
//                
//                ForEach(Array(stride(from: 100, through: 1000, by: 50)), id: \.self) { value in
//                    Text("\(value)")
//                        .tag(value)
//                }
//            }
//            .pickerStyle(.wheel)
//            .frame(width: 100, height: 100)
//            
//            Button(action: {
////                homeVM.updateDailyTarget(dailyTarget: selectedValue)
//                showPicker.toggle()
//            }) {
//                Image(systemName: Constants.IconTextConstants.okButtonRectangle)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 40, height: 40)
//                    .foregroundColor(.blue.opacity(0.6))
//                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
//            }
//            .padding(.leading, 20)
//            .buttonStyle(PlainButtonStyle())
//        }
//        .environment(\.locale, .init(identifier: languageManager.currentLanguage))
//        
//    }
//}

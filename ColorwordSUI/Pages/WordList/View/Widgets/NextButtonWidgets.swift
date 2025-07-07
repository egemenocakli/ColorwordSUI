//
//  NextButtonWidgets.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 16.11.2024.
//

import SwiftUI

struct NextButtonWidgets: View {
    @Binding var selectedTabIndex: Int
    @ObservedObject var wordListVM : WordListViewModel
    var body: some View {
        
        
        HStack {
                       Button {
                           
                           if selectedTabIndex > 0 {
                               selectedTabIndex -= 1
                           }
                       } label: {
                           Image(systemName: Constants.IconTextConstants.leftButton)
                               .resizable()
                               .scaledToFit()
                               .frame(width: Constants.FrameSizeConstants.smallSize, height: Constants.FrameSizeConstants.lSize)
                               .padding(.leading, Constants.PaddingSizeConstants.xxSmallSize)
                               .foregroundColor(selectedTabIndex == 0 ? .gray : .white.opacity(0.7))
                       }
                       .disabled(selectedTabIndex == 0)
                       
            Spacer()
                       
                       Button {
                          
                           if selectedTabIndex < self.wordListVM.wordList.count - 1 {
                               selectedTabIndex += 1
                           }
                       } label: {
                           Image(systemName: Constants.IconTextConstants.rightButton)
                               .resizable()
                               .scaledToFit()
                               .frame(width: Constants.FrameSizeConstants.smallSize, height: Constants.FrameSizeConstants.lSize)
                               .padding(.trailing, Constants.PaddingSizeConstants.xxSmallSize)
                               .foregroundColor(selectedTabIndex == wordListVM.wordList.count - 1 ? .gray : .white.opacity(0.7))
                       }
                       .disabled(selectedTabIndex == self.wordListVM.wordList.count - 1)
                   }
    }
}

//#Preview {
//
//    NextButtonWidgets()
//}

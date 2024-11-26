//
//  MchoiceTestView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 22.11.2024.
//

import SwiftUI

struct MchoiceTestView: View {
    @StateObject var mchoiceTestVM = MchoiceTestViewModel()
    @State private var selectedTabIndex = 0
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTabIndex) {
                ForEach(Array(mchoiceTestVM.questList.enumerated()), id: \.element.word.wordId) { index, quest in
                    VStack {
                        Text(quest.word.word ?? "")
                            .fontWeight(.bold)
                            .font(.system(size: Constants.FontSizeConstants.x4Large))
                            .foregroundStyle(Color.textColorWhite)
                        
                        Text(quest.word.translatedWords?.first ?? "")
                            .font(.system(size: Constants.FontSizeConstants.x3Large))
                            .foregroundStyle(Color.textColorWhite)
                        
                        //Ya bu doğru kelime correct bilgisini yanında getircez ya da burada atayacağız atandığında rengi optionstate e göre değişecek. Sanırım karar burada belirlenecek önceden gelirse doğru veya yanlışta buttonbackground rengi değişecek çünkü
                        Text(quest.options[0].optionText + " (\(quest.options[0].optionState))")
                        Text(quest.options[1].optionText + " (\(quest.options[1].optionState))")
                        Text(quest.options[2].optionText + " (\(quest.options[2].optionState))")
                        Text(quest.options[3].optionText + " (\(quest.options[3].optionState))")
                    }
                    .padding(.horizontal, Constants.PaddingSizeConstants.lmSize)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .tag(index)
                }
            }.background(Color.backgroundColorGradient1)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }.task {
            mchoiceTestVM.questList = await mchoiceTestVM.createThreeUniqueOption()
        }
    }
        
}

#Preview {
    MchoiceTestView()
}

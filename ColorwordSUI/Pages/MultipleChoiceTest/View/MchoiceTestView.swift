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
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack (alignment: .center){
            
            VStack {
                //Loading gösterilebilir hatta yüklenmezse bu uyarı yazılabilir.
                if (mchoiceTestVM.wordList.isEmpty) {
                    Text("no_data").padding(.horizontal, Constants.PaddingSizeConstants.lmSize).frame(alignment: .center)
                        .background(Color.white.opacity(0.00))
                } else {
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
                                    Button(action: {
//                                        if (mchoiceTestVM.isPressed1 == true && quest.options[0].optionText == quest.word.translatedWords?[0].description ?? "") {
//                                            quest.options[0].optionState = .correct
//                                        }
                                    }) {
                                      Text(quest.options[0].optionText + " (\(quest.options[0].optionState))")
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(.white.opacity(0.1))
                                        .cornerRadius(100)
                                    }
                                    .padding(.all, 10)

                                    Button(action: {}) {
                                      Text(quest.options[1].optionText + " (\(quest.options[1].optionState))")
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(.white.opacity(0.1))
                                        .cornerRadius(100)
                                    }
                                    .padding(.all, 10)

                                    Button(action: {}) {
                                      Text(quest.options[2].optionText + " (\(quest.options[2].optionState))")
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(.white.opacity(0.1))
                                        .cornerRadius(100)
                                    }
                                    .padding(.all, 10)

                                    Button(action: {}) {
                                      Text(quest.options[3].optionText + " (\(quest.options[3].optionState))")
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(.white.opacity(0.1))
                                        .cornerRadius(100)
                                    }
                                    .padding(.all, 10)

//                                    Text(quest.options[0].optionText + " (\(quest.options[0].optionState))")
//                                    Text(quest.options[1].optionText + " (\(quest.options[1].optionState))")
//                                    Text(quest.options[2].optionText + " (\(quest.options[2].optionState))")
//                                    Text(quest.options[3].optionText + " (\(quest.options[3].optionState))")
                                }
                                .padding(.horizontal, Constants.PaddingSizeConstants.lmSize)
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .onAppear {
                            if let firstWord = mchoiceTestVM.wordList.first {
                                mchoiceTestVM.getWordColorForBackground(word: firstWord,themeManager: themeManager)
                            }
                        }
                        .onChange(of: selectedTabIndex) { oldIndex, newIndex in
                            let word = mchoiceTestVM.wordList[newIndex]
                            mchoiceTestVM.getWordColorForBackground(word: word,themeManager: themeManager)
                        }
                    }
                }
            }
            .background(Color(hex: mchoiceTestVM.wordBackgroundColor))
            .edgesIgnoringSafeArea(.all)
            .task {
                mchoiceTestVM.questList = await mchoiceTestVM.createThreeUniqueOption()
            }
            
        }
    }
}

#Preview {
    MchoiceTestView()
}

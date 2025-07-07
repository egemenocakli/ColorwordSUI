//
//  HomeView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 4.02.2025.
//

import SwiftUI



//TODO: Arka plan rengi kalıcı siyah yerine temaya göre değişecek
struct HomeView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var homeVM = HomeViewModel.shared
    let categories: [CategoryItem] = [
    CategoryItem(title: "Word List", icon: "list.bullet.rectangle", color: .blue, destination: AnyView(WordListView())),
    CategoryItem(title: "Multiple Choice Test", icon: "checklist", color: .purple, destination: AnyView(MchoiceTestView())),
    CategoryItem(title: "Profile", icon: "person.crop.circle", color: .purple, destination: AnyView(ProfileView())),
    CategoryItem(title: "Scoreboard", icon: "list.number", color: .purple, destination: AnyView(ScoreboardView())),
    CategoryItem(title: "UserWordListPickView", icon: "list.bullet.rectangle", color: .purple, destination: AnyView(WordListSelectorView())),
    ]

    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State private var navigateToLogin = false

    
    var body: some View {
        NavigationStack {
            ZStack{
                Constants.ColorConstants.loginLightThemeBackgroundGradient.edgesIgnoringSafeArea(.all)
                GeometryReader { geometry in
                    
                    VStack {
                        
                        DailyProgressView(progress: Double(homeVM.dailyProgressBarPoint),dailyTarget: Double(homeVM.dailyTarget))

                        
                        // Kategori Grid
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(categories) { category in
                                NavigationLink(destination: category.destination) {
                                    CategoryButton(category: category)
                                }
                            }
                        }
                        .padding()
                        
                        Spacer()
                        
//                        Button {
//                            homeVM.increaseUserInfoPoints(increaseBy: 10)
//                        } label: {
//                            Text("DailyPoint arttır")
//                        }


                    }
                    //                .background(Color.black.edgesIgnoringSafeArea(.all))
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                homeVM.signOut { success in
                                        if success {
                                            navigateToLogin = true
                                        } else {
                                            
                                        }
                                    }
                                
                                
                            }) {
                                Image(systemName: Constants.IconTextConstants.logOutButton)
                                    .font(.system(size: Constants.FontSizeConstants.x2Large))
                                    .foregroundColor(Constants.ColorConstants.grayButtonColor)
                            }
                        }
                        
                    }
                    .environment(\.locale, .init(identifier: languageManager.currentLanguage))
                    .preferredColorScheme(themeManager.colorScheme)
                    .navigationDestination(isPresented: $navigateToLogin) {
                        LoginView().navigationBarBackButtonHidden(true)
                        
                    }
                }
            }
            
        }

        .onAppear {
            if homeVM.loginSuccess {
            homeVM.fetchUserDailyPoint()
            }
        }
        .onChange(of: homeVM.loginSuccess, initial: false) { oldValue, newValue in
            if newValue {
            homeVM.fetchUserDailyPoint()
           }
        }

    }
    
    // Kategori Butonu Bileşeni
    struct CategoryButton: View {
        let category: CategoryItem
        
        var body: some View {
            VStack {
                Image(systemName: category.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding()
                    .foregroundStyle(Color(.white))
                //                .background(RoundedRectangle(cornerRadius: 20).fill(category.color.opacity(0.2)))
                
                Text(category.title)
                    .foregroundColor(.white)
                    .font(.headline)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 140, height: 120)
            .padding()
            .background(RoundedRectangle(cornerRadius: 20).fill(Constants.ColorConstants.homeCardBackgroundColor))
            .shadow(radius: 5)
        }
    }
    
}

// Önizleme
#Preview {
    HomeView()
}

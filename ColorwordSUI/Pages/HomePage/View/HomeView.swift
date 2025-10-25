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
    @EnvironmentObject var session: UserSessionManager

    
    //TODO: constantstan çekilecek. ve localization eklenecek aşağıdakilere
    let categories: [CategoryItem] = [
        CategoryItem(title: "Word List", icon: "list.bullet.rectangle", color: .blue, destination: AnyView(WordListSelectorView(selectedTargetPage: "wordList"))),
        CategoryItem(title: "Multiple Choice Test", icon: "checklist", color: .purple, destination: AnyView(WordListSelectorView(selectedTargetPage: "multipleChoiceTest"))),
        CategoryItem(title: "Profile", icon: "person.crop.circle", color: .purple, destination: AnyView(ProfileView())),
        CategoryItem(title: "Leaderboard", icon: "trophy", color: .purple, destination: AnyView(LeaderboardView())),
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
                            .onAppear {
                                homeVM.fetchUserDailyPoint()
                            }

                        
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
                                            UserSessionManager.shared.logout()
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
            homeVM.fetchUserDailyPoint()
        }

        .onChange(of: session.currentUser?.userId ?? "", initial: false) { _, newId in
            if !newId.isEmpty {
                homeVM.resetForNewUser() 
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

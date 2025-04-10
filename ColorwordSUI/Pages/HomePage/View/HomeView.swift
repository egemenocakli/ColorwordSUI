//
//  HomeView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 4.02.2025.
//

import SwiftUI



//TODO: Arka plan rengi kalıcı siyah yerine temaya göre değişecek
struct HomeView: View {
    
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var homeVM = HomeViewModel()
    let categories: [CategoryItem] = [
    CategoryItem(title: "Word List", icon: "list.bullet.rectangle", color: .blue, destination: AnyView(WordListView())),
    CategoryItem(title: "Multiple Choice Test", icon: "checklist", color: .purple, destination: AnyView(MchoiceTestView())),
    CategoryItem(title: "Profile", icon: "person.crop.circle", color: .purple, destination: AnyView(ProfileView())),
    CategoryItem(title: "Scoreboard", icon: "list.number", color: .purple, destination: AnyView(ScoreboardView())),
    ]

    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State private var navigateToLogin = false

    
    var body: some View {
        NavigationStack {
            VStack {

                //TODO: Günlük kazanılan puan tutulacak. Belki girişten bile +10 puan verilebilir. Ancak hangi kelimeye
                //TODO: yansıyacak o kısım dert.
                // ilk girişte 0/10 olacak. 10 u aşarsa 10/25 falan 25 i aşarsa 25/100 olacak şeklinde devam edecek.
                //Renkler açık temaya da uyarlanacak
                DailyProgressView()
                
                
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
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if homeVM.signOut() == true {
                                navigateToLogin = true
                            
                            }else {
                                
                            }
                        
                        
                    }) {
                        Image(systemName: Constants.IconTextConstants.logOutButton)
                            .font(.system(size: Constants.FontSizeConstants.x2Large))
                            .foregroundColor(Constants.ColorConstants.grayButtonColor)
                    }
                }
                
            }
            .environment(\.locale, .init(identifier: languageManager.currentLanguage))
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView().navigationBarBackButtonHidden(true)
                
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
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.1)))
            .shadow(radius: 5)
        }
    }
    
}

// Önizleme
#Preview {
    HomeView()
}

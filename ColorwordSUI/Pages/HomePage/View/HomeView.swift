//
//  HomeView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 4.02.2025.
//

import SwiftUI


let categories: [CategoryItem] = [
    CategoryItem(title: "Word List", icon: "list.bullet.rectangle", color: .blue, destination: AnyView(WordListView())),
    CategoryItem(title: "Multiple Choice Test", icon: "checklist", color: .purple, destination: AnyView(MchoiceTestView())),
]

let columns = [GridItem(.flexible()), GridItem(.flexible())]

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                // Üst Kısım (Header)
                ZStack {
                    
                            VStack {
                                Text("Classify transaction")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Classify this transaction into a particular category")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding()
                       
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
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            
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



// Önizleme
#Preview {
    HomeView()
}

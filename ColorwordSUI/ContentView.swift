//
//  ContentView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 17.10.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        
        
        GeometryReader { geometry in
            VStack {
                Text("Colorword").frame(width: UIScreen.main.bounds.width, height: 100, alignment: .center).font(.system(size: 60))
                    .frame(height: geometry.size.height * 0.3)
              
                GeometryReader { geometry in
                    VStack {
                        
                        
                        TextField("Email", text: $email)
                            .font(.callout)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
                            .padding(.all, 10)
                        
                        
                        TextField("Password", text: $password)
                            .font(.callout)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
                            .padding(.all, 10)
                            
                        
                        
                        Button(action: loginButton) {
                            Text("Login")
                                .foregroundStyle(.white)
                                .frame(width: 100, height: 50)
                                .background(Color.green.opacity(0.90))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .contentShape(Rectangle())
                        
                        Button(action: loginButton) {
                            Text("Sign Up")
                                .foregroundStyle(.white)
                                .frame(width: 100, height: 50)
                                .background(Color.blue.opacity(0.80))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .contentShape(Rectangle())
                        .padding(.top, 10)
                        
                        
                        
                        
                        
                    }
                    .padding(.horizontal, 20)
                    .frame(height: geometry.size.height * 0.6)
                }
                
            }
        }
        
    }
    
    func loginButton() {
        
    }
}
    
#Preview {
    ContentView()
}


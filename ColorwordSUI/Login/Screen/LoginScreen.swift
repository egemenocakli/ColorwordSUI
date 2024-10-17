//
//  ContentView.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 17.10.2024.
//

import SwiftUI


struct LoginScreen: View {
    
    @State var email: String = ""
    @State var password: String = ""

    var body: some View {
        
        
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                            LinearGradient(gradient: Gradient(colors: [
                                Color(red: 0.0, green: 0.1, blue: 0.2), // Alttaki koyu mavi
                                Color.black // Üstte siyah
                            ]), startPoint: .bottom, endPoint: .top)
                            .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Colorword").frame(width: UIScreen.main.bounds.width, height: 100, alignment: .center).font(.system(size: 60))
                        .frame(height: geometry.size.height * 0.3)
                        .foregroundStyle(.white)
                    
                    GeometryReader { geometry in
                        VStack {
                            
                            
                            VStack {
                                 ZStack(alignment: .leading) {
                                     if email.isEmpty {
                                         Text("Email")
                                             .foregroundColor(.gray)  // Placeholder rengini burada ayarlıyoruz
                                             .padding(.leading, 40)
                                     }
                                     TextField("", text: $email)
                                         .padding()
                                         .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.70), lineWidth: 2))
                                         .padding(.all, 10)
                                         .foregroundColor(.white)  // Asıl yazı rengi
                                 }
                             }
                            
                            VStack {
                                 ZStack(alignment: .leading) {
                                     if password.isEmpty {
                                         Text("Password")
                                             .foregroundColor(.gray)  // Placeholder rengini burada ayarlıyoruz
                                             .padding(.leading, 40)
                                     }
                                     TextField("", text: $password)
                                         .padding()
                                         .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.70), lineWidth: 2))
                                         .padding(.all, 10)
                                         .foregroundColor(.white)  // Asıl yazı rengi
                                 }
                             }
                         
                            
                            
                            Button(action: loginButton) {
                                Text("Login")
                                    .foregroundStyle(.white)
                                    .frame(width: 100, height: 50)
                                    .background(Color(red: 100/255, green: 13/255, blue: 95/255))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .contentShape(Rectangle())
                            
                            Button(action: loginButton) {
                                Text("Sign Up")
                                    .foregroundStyle(.white)
                                    .frame(width: 100, height: 50)
                                    .background(Color.gray)
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
        
    }

    
    func loginButton() {
        
    }
}
    
#Preview {
    LoginScreen()
}


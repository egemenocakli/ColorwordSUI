//
//  SignupViewmodel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 7.02.2025.
//

import Foundation

class SignupViewModel: ObservableObject {
    
    @Published  var email: String = ""
    @Published  var password: String = ""
    @Published  var name: String = ""
    @Published  var lastName: String = ""
    
    //TODO: Kayıt olma işlemi + benim kayıt ettiğim kullanıcı bilgileri metodu çağrılacak.
    
}

//
//  AuthServiceInterface.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 21.10.2024.
//

import Foundation
import FirebaseAuth

protocol AuthServiceInterface {
    //    func signInWithGoogle(completion: @escaping (FirebaseUserModel?) -> Void)
    //    func getCurrentUser() -> FirebaseUserModel?
    func signOut(completion: @escaping (Bool) -> Void)
    //    func updateName(displayName: String, completion: @escaping (Bool) -> Void)
    //    func updateEmail(email: String, completion: @escaping (Bool) -> Void)
    //    func deleteAccount(completion: @escaping (Bool) -> Void)
    func signUp(email: String, password: String, name: String, lastName: String, completion: @escaping (Bool) -> Void)
    func loginWithEmailPassword(email: String, password: String, completion: @escaping (Bool, FirebaseUserModel?) -> Void)
}

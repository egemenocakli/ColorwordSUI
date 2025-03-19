//
//  HomeService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 6.02.2025.
//

protocol HomeServiceInterface {
    func signOut(completion: @escaping (Bool) -> Void)
    func fetchUserDailyPoint(userId: String, completion: @escaping (UserInfoModel?) -> Void)
}

class HomeService {
    private let firebaseAuthService = FirebaseAuthService()
    private let firestoreService = FirestoreService()

    
    func signOut(completion: @escaping (Bool) -> Void) {
        firebaseAuthService.signOut { result in
            completion(result)
        }
    
    }
    
    func fetchUserDailyPoint(userId: String, completion: @escaping (UserInfoModel?) -> Void) {
        firestoreService.fetchUserInfo(userId: userId) { userInfoModel in
            completion(userInfoModel)
        }
    }
    
}

//
//  HomeService.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 6.02.2025.
//

protocol HomeServiceInterface {
    func signOut(completion: @escaping (Bool) -> Void)
    func fetchUserDailyPoint(userId: String, completion: @escaping (UserInfoModel?) -> Void)
    func increaseUserInfoPoints(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void)
    func resetDailyScoreIfFirstTime(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void)
    func changeDailyTarget(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void)
    
}

//TODO: async e geçilecek
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
    
    func increaseUserInfoPoints(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void) {
        
        firestoreService.increaseDailyPoints(for: userInfo) { result in
            completion(result)
        }
    }
    func resetDailyScoreIfFirstTime(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void) {
        
        firestoreService.increaseDailyPoints(for: userInfo) { result in
            completion(result)
        }
    }
    
    func changeDailyTarget(for userInfo: UserInfoModel, completion: @escaping (Bool) -> Void) {
        
        firestoreService.changeDailyTarget(for: userInfo) { result in
            completion(result)
        }
    }
}

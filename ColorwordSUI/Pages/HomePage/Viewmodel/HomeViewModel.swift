//
//  HomeViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 6.02.2025.
//

import Foundation

final class HomeViewModel: ObservableObject {
    let homeService = HomeService()
    let userPreferences = UserPreferences()
    let keychainEncrpyter = KeychainEncrpyter()
    @Published var dailyProgressBarPoint: Int = 0
    @Published var dailyTarget: Int = 100
    @Published var loginSuccess: Bool = false
    @Published var userInfoModel: UserInfoModel?
    

    //Burada autologinden userId içeriği henüz dolmadan fetchUserDailyPoint çağrılıyor o sebepten signletona çevirdim.
    static let shared = HomeViewModel()
    
    func changeLoginSuccesState () {
        loginSuccess = !loginSuccess
    }
    
    func signOut(completion: @escaping (Bool) -> Void) {
        homeService.signOut { response in
            if response {
                DispatchQueue.main.async {
                    self.userPreferences.savedEmail = ""
                    self.keychainEncrpyter.deletePassword()
                    self.loginSuccess = false 
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
    
    
    func fetchUserDailyPoint ()  {
       
        guard let userId =  UserSessionManager.shared.currentUser?.userId else {
            dailyProgressBarPoint = 0
            return
        }
        
        homeService.fetchUserDailyPoint(userId: userId) { userInfoModel in
            UserSessionManager.shared.updateUserInfoModel(with: userInfoModel!)
            self.userInfoModel = userInfoModel
            self.resetDailyScoreIfFirstTime()
            self.dailyTarget = userInfoModel?.dailyTarget ?? Constants.ScoreConstants.dailyTargetScore

        }
    }
    

    

    //Alert olacak +10 sebebi olarak bir bildirim olabilir
    func resetDailyScoreIfFirstTime () {
        
        if let lastScoreDate = userInfoModel?.dailyScoreDate,
           !Calendar.current.isDate(lastScoreDate, inSameDayAs: Date()) {
            print("ilk defa giriş yapıldı")
            
            guard let currentUser = UserSessionManager.shared.currentUser else {
                print("UserSessionManager.shared.currentUser bulunamadı")
                return
            }
            
            guard let userInfoModel = self.userInfoModel else {
                print("userInfoModel bulunamadı")
                return
            }
            
            
            var userInfo = UserInfoModel(userId: currentUser.userId, email: currentUser.email, name: currentUser.name, lastname: currentUser.lastname, dailyTarget: userInfoModel.dailyTarget)
            
            userInfo.dailyScore = Constants.ScoreConstants.dailyLoginScoreBonus
            userInfo.totalScore = userInfoModel.totalScore + Constants.ScoreConstants.dailyLoginScoreBonus
                
                self.homeService.increaseUserInfoPoints(for: userInfo) { result in
                    if result {
                        print("Kullanıcı puanları başarılı şekilde sıfırlandı.")
                        self.userInfoModel?.dailyScore = Constants.ScoreConstants.dailyLoginScoreBonus
                        self.dailyProgressBarPoint = Constants.ScoreConstants.dailyLoginScoreBonus
                    }else {
                        print("Puan sıfırlama işlemi başarısız oldu.")
                    }
            }
        }
        else {
            DispatchQueue.main.async {
                self.dailyProgressBarPoint = self.userInfoModel?.dailyScore ?? 0
            }
        }
    }
    
    //Eğer kullanıcı o gün ilk defa giriyorsa +10 puan vericez.
    //toplamscore a da eklenecek.
    //belki bir uyarı ile +10 puanı kullanıcıya gösterebiliriz.
    
    
    //yapılacak kontroller:
    //giriş yapılan günün tarihi ile userInfo tarihi farklıysa = 0
    //eğer değer 0 sa uyarı verip giriş yaptığınız için +10 ekledik haberiniz olsun alert
    //
    
    //sadece daily ve totalpoints arttırıyor
    func increaseUserInfoPoints(increaseBy: Int) {
        
        guard let currentUser = UserSessionManager.shared.currentUser else {
            print("UserSessionManager.shared.currentUser bulunamadı")
            return
        }
        
        guard self.userInfoModel != nil else {
            print("userInfoModel bulunamadı")
            return
        }

        
        var currentUserInfo = UserInfoModel(userId: currentUser.userId, email: currentUser.email, name: currentUser.name, lastname: currentUser.lastname, dailyTarget: userInfoModel?.dailyTarget ?? Constants.ScoreConstants.dailyTargetScore)
        
        currentUserInfo.dailyScore += self.userInfoModel!.dailyScore + increaseBy
        currentUserInfo.totalScore += self.userInfoModel!.totalScore + increaseBy
        
        print("Yeni dailyScore: \(currentUserInfo.dailyScore)")
        print("Yeni totalScore: \(currentUserInfo.totalScore)")
        print("dailyscore: \(increaseBy)")
        
            homeService.increaseUserInfoPoints(for: currentUserInfo) { result in
                if result {
                    self.userInfoModel = currentUserInfo
                    self.dailyProgressBarPoint = currentUserInfo.dailyScore
                    print("Kullanıcı puanları başarılı şekilde güncellendi.")
                }else {
                    print("Puan güncelleme işlemi başarısız oldu.")
                }
            }
        
    }
    
    
    func updateDailyTarget (dailyTarget: Int) {
        

        guard let currentUser = UserSessionManager.shared.currentUser else {
            print("UserSessionManager.shared.currentUser bulunamadı")
            return
        }
        
        guard self.userInfoModel != nil else {
            print("userInfoModel bulunamadı")
            return
        }
            
        var userInfo = UserInfoModel(userId: currentUser.userId, email: currentUser.email, name: currentUser.name, lastname: currentUser.lastname, dailyTarget: Constants.ScoreConstants.dailyTargetScore)
            
        userInfo.dailyTarget = dailyTarget
                
        self.homeService.changeDailyTarget (for: userInfo) { result in
                    if result {
                        print("Hedef skor güncellendi." )
                        self.userInfoModel?.dailyTarget = Constants.ScoreConstants.dailyTargetScore
                        self.fetchUserDailyPoint()
                    }else {
                        print("Hedef skor güncellenemedi.")
                    }
            }
        }

    
    
}

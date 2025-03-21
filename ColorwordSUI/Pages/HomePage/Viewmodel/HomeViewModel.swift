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
    @Published var loginSuccess: Bool = false
    var userInfoModel: UserInfoModel?

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
            self.userInfoModel = userInfoModel
            self.resetDailyScoreIfFirstTime()

                    DispatchQueue.main.async {
                        self.dailyProgressBarPoint = userInfoModel?.dailyScore ?? 0
                    }
        }
    }
    

    
    //TODO: Şuanda tek sorun: Geçmişte kullanıcı 40 puandaysa bar önce 40 a gidiyo sonra yeni gün olduğundan 10 a düşüyor
    //Eğer o gün ilk defa giriş yapıyorsa +10 verecek method
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
            
            
            var userInfo = UserInfoModel(userId: currentUser.userId, email: currentUser.email, name: currentUser.name, lastname: currentUser.lastname)
            
            userInfo.dailyScore = 10
            userInfo.totalScore = userInfoModel.totalScore + 10
                
                self.homeService.increaseUserInfoPoints(for: userInfo) { result in
                    if result {
                        print("Kullanıcı puanları başarılı şekilde sıfırlandı.")
                        self.userInfoModel?.dailyScore = 10
                        self.dailyProgressBarPoint = 10
                    }else {
                        print("Puan sıfırlama işlemi başarısız oldu.")
                    }
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
        
        guard let userInfoModel = self.userInfoModel else {
            print("userInfoModel bulunamadı")
            return
        }
        
        var userInfo = UserInfoModel(userId: currentUser.userId, email: currentUser.email, name: currentUser.name, lastname: currentUser.lastname)
        
        userInfo.dailyScore = userInfoModel.dailyScore + increaseBy
        userInfo.totalScore = userInfoModel.totalScore + increaseBy
        
        print("userInfoModel dailyscore: \(userInfo.dailyScore)")
        print("userInfoModel dailyscore: \(userInfo.totalScore)")
        print("userInfo dailyscore: \(userInfo.dailyScore)")
        print("userInfo dailyscore: \(userInfo.totalScore)")
        print("dailyscore: \(increaseBy)")
            homeService.increaseUserInfoPoints(for: userInfo) { result in
                if result {
                    print("Kullanıcı puanları başarılı şekilde güncellendi.")
                }else {
                    print("Puan güncelleme işlemi başarısız oldu.")
                }
            }
        
    }
}

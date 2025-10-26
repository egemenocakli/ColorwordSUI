//
//  HomeViewModel.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 6.02.2025.
//

import Foundation
import Combine


@MainActor
final class HomeViewModel: ObservableObject {
    static let shared = HomeViewModel()

    let homeService = HomeService()
    let userPreferences = UserPreferences()
    let keychainEncrpyter = KeychainEncrpyter()

    @Published var dailyProgressBarPoint: Int = 0
    @Published var dailyTarget: Int = 100
    @Published var loginSuccess: Bool = false
    @Published var userInfoModel: UserInfoModel?

    private var cancellables = Set<AnyCancellable>()
    @Published private var currentUserIdSnapshot: String?
    
    @Published private var isFetching = false
    @Published private var isResettingDaily = false



    private init() {
        // 1) currentUser değişince:
        UserSessionManager.shared.$currentUser
            .removeDuplicates(by: { $0?.userId == $1?.userId })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self else { return }
                if user != nil {
                    // Kullanıcı geldi -> günlük puanı çek
                    self.fetchUserDailyPoint()
                } else {
                    // Kullanıcı gitti -> view state'i sıfırla
                    self.userInfoModel = nil
                    self.dailyProgressBarPoint = 0
                    self.dailyTarget = Constants.ScoreConstants.dailyTargetScore
                }
            }
            .store(in: &cancellables)

        // 2) UserSessionManager.userInfoModel güncellenince:
        UserSessionManager.shared.$userInfoModel
            .compactMap { $0 } // nil değilse
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                guard let self else { return }
                self.userInfoModel = info
                self.dailyTarget = info.dailyTarget
            }
            .store(in: &cancellables)
    }

    @MainActor
    func resetForNewUser() {
        userInfoModel = nil
        dailyProgressBarPoint = 0
        dailyTarget = Constants.ScoreConstants.dailyTargetScore
    }
    
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
                    self.dailyProgressBarPoint = 0

                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
    
    
    @MainActor
    func fetchUserDailyPoint() {
        guard let uid = UserSessionManager.shared.currentUser?.userId else {
            dailyProgressBarPoint = 0
            return
        }
        // ← aynı anda birden fazla fetch’i engelle
        guard !isFetching else { return }
        isFetching = true

        currentUserIdSnapshot = uid

        homeService.fetchUserDailyPoint(userId: uid) { [weak self] model in
            guard let self else { return }
            Task { @MainActor in
                defer { self.isFetching = false } // ← kilidi bırak

                guard self.currentUserIdSnapshot == UserSessionManager.shared.currentUser?.userId else { return }

                if let model {
                    self.userInfoModel = model
                    self.dailyTarget = model.dailyTarget
                    self.resetDailyScoreIfFirstTime()

                    if let updated = self.userInfoModel {
                        UserSessionManager.shared.updateUserInfoModel(with: updated)
                    }
                } else {
                    // no-op
                }
            }
        }
    }



    //Alert olacak +10 sebebi olarak bir bildirim olabilir
    @MainActor
    func resetDailyScoreIfFirstTime() {
        // ← aynı anda birden fazla reseti engelle
        guard !isResettingDaily else { return }
        isResettingDaily = true
        defer { isResettingDaily = false }

        guard var info = self.userInfoModel else {
            debugPrint("userInfoModel bulunamadı"); return
        }
        guard let uid = UserSessionManager.shared.currentUser?.userId,
              uid == info.userId else { return }

        let today = Date()
        let bonus = Constants.ScoreConstants.dailyLoginScoreBonus

        let isSameDay = (info.dailyScoreDate != nil) &&
                        Calendar.current.isDate(info.dailyScoreDate!, inSameDayAs: today)

        var delta = 0

        if isSameDay {
            if info.dailyScore < bonus {
                delta = bonus - info.dailyScore
                info.dailyScore = bonus
                info.totalScore += delta
            }
        } else {
            delta = bonus
            info.dailyScore = bonus
            info.totalScore += bonus
        }

        info.dailyScoreDate = today

        // UI
        self.userInfoModel = info
        self.dailyProgressBarPoint = info.dailyScore
        self.dailyTarget = info.dailyTarget

        let snapshot = uid
        homeService.increaseUserInfoPoints(for: info) { [weak self] ok in
            guard let self else { return }
            Task { @MainActor in
                guard snapshot == UserSessionManager.shared.currentUser?.userId else { return }
                if ok {
                    UserSessionManager.shared.updateUserInfoModel(with: info)
                    if delta > 0 {
                        try? await self.homeService.updateLeaderboardScore(by: delta, userInfo: info)
                    }
                } else {
                    debugPrint("Puan (ilk giriş/reset) yazılamadı.")
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

    @MainActor
    func increaseUserInfoPoints(increaseBy: Int) {
        guard let currentUser = UserSessionManager.shared.currentUser else {
            debugPrint("currentUser yok"); return
        }
        guard var info = self.userInfoModel, info.userId == currentUser.userId else {
            // Model hazır değilse çek; ama reset tetiklemesin diye önceki fonksiyon tarih damgalıyor
            fetchUserDailyPoint()
            return
        }

        info.dailyScore += increaseBy
        info.totalScore += increaseBy
        info.dailyScoreDate = Date() // ÖNEMLİ: her artışta bugüne damgala

        // UI'ı anında güncelle
        self.userInfoModel = info
        self.dailyProgressBarPoint = info.dailyScore

        let snapshot = currentUser.userId
        homeService.increaseUserInfoPoints(for: info) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                guard snapshot == UserSessionManager.shared.currentUser?.userId else { return }
                if result {
                    UserSessionManager.shared.updateUserInfoModel(with: info)
                    debugPrint("Kullanıcı puanları güncellendi.")
                } else {
                    debugPrint("Puan güncelleme işlemi başarısız oldu.")
                }
            }
        }
    }

    
    
    @MainActor
    func updateDailyTarget(dailyTarget: Int) {
        guard let currentUser = UserSessionManager.shared.currentUser else {
            debugPrint("UserSessionManager.shared.currentUser bulunamadı"); return
        }
        // userInfoModel hazır değilse bir kez çekmeyi dene
        if userInfoModel == nil { fetchUserDailyPoint() }
        guard userInfoModel != nil else {
            debugPrint("userInfoModel bulunamadı"); return
        }

        var userInfo = UserInfoModel(
            userId: currentUser.userId,
            email: currentUser.email,
            name: currentUser.name,
            lastname: currentUser.lastname,
            dailyTarget: userInfoModel?.dailyTarget ?? Constants.ScoreConstants.dailyTargetScore
        )
        userInfo.dailyTarget = dailyTarget

        homeService.changeDailyTarget(for: userInfo) { result in
            if result {
                debugPrint("Hedef skor güncellendi.")
                DispatchQueue.main.async {
                    self.userInfoModel?.dailyTarget = dailyTarget // seçilen değeri yaz
                    self.dailyTarget = dailyTarget
                    self.fetchUserDailyPoint()
                }
            } else {
                debugPrint("Hedef skor güncellenemedi.")
            }
        }
    }


    
    
}

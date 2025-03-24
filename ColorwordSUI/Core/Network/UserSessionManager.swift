import Foundation

final class UserSessionManager {
    static let shared = UserSessionManager()

    private(set) var currentUser: FirebaseUserModel?
    private(set) var userInfoModel: UserInfoModel?
    
    var phoneNumber: String? // Sonradan doldurulacak telefon numarası gibi ek bir alan

    
    private init() {}

    func updateUser(with user: FirebaseUserModel) {
        self.currentUser = user
    }
    func updateUserInfoModel(with user: UserInfoModel) {
        self.userInfoModel = user
    }

    func updatePhoneNumber(_ phone: String) {
        self.phoneNumber = phone
    }

    func logout() {
        self.currentUser = nil
        self.phoneNumber = nil
        self.userInfoModel = nil
        
        // Ek alanları da sıfırlayın
        // Otomatik çıkış işlemi veya Firebase logout çağrısı yapılabilir
    }
}


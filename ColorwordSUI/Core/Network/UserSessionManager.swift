import SwiftUI
import FirebaseAuth

final class UserSessionManager: ObservableObject {
    static let shared = UserSessionManager()

    @Published private(set) var currentUser: FirebaseUserModel? //TODO: ne demek bu? private set
    @Published private(set) var userInfoModel: UserInfoModel?
    @Published var phoneNumber: String?

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
        self.userInfoModel = nil
        self.phoneNumber = nil
        try? Auth.auth().signOut()
    }
}

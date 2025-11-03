import Foundation
import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

@MainActor
final class UserSessionManager: ObservableObject {
    static let shared = UserSessionManager()

    @Published private(set) var currentUser: FirebaseUserModel?
    @Published private(set) var userInfoModel: UserInfoModel?
    @Published var isRestoring: Bool = true

    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    private var authHandle: AuthStateDidChangeListenerHandle?

    private let skipKey = "skipAutoLogin"
    private let userPrefs = UserPreferences()
    private let keychain = KeychainEncrpyter()
    
    // İstersen mevcut servislerini de kullanabilirsin
    private let firebaseAuthService = FirebaseAuthService()

    private init() {
        // 1) Firebase auth state tek dinleyici
        authHandle = auth.addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            Task { @MainActor in
                if let u = user {
                    // FirebaseUserModel'i doldur
                    let nameParts = (u.displayName ?? "").split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                    let name = nameParts.first.map(String.init) ?? ""
                    let last = nameParts.count > 1 ? String(nameParts[1]) : ""
                    let appUser = FirebaseUserModel(userId: u.uid, email: u.email ?? "", name: name, lastname: last)
                    self.currentUser = appUser

                    // Kullanıcının userInfo dokümanını getir/oluştur
                    let info = try? await self.fetchOrCreateUserInfo(
                        userId: u.uid,
                        name: u.displayName ?? name,
                        email: u.email ?? ""
                    )
                    self.userInfoModel = info
                } else {
                    self.currentUser = nil
                    self.userInfoModel = nil
                }
            }
        }

        // 2) Açılışta auto-restore
        Task { await restoreIfPossible() }
    }

    deinit {
        if let h = authHandle { auth.removeStateDidChangeListener(h) }
    }

    // MARK: - Public updaters (isteğe bağlı, dış API’n ile uyum)
    func updateUser(with user: FirebaseUserModel) { self.currentUser = user }
    func updateUserInfoModel(with user: UserInfoModel) { self.userInfoModel = user }

    // MARK: - Restore akışı
    func restoreIfPossible() async {
        defer { isRestoring = false }

        // Çıkıştan sonra bir sonraki açılışta auto-login istemiyorsak
        if UserDefaults.standard.bool(forKey: skipKey) { return }

        // Firebase zaten oturum tutuyorsa (token persist) → listener tetikler
        if auth.currentUser != nil { return }

        // 1) Google oturumu varsa sessizce geri yükle
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            do {
                let gUser = try await withCheckedThrowingContinuation { (c: CheckedContinuation<GIDGoogleUser, Error>) in
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, err in
                        if let err { c.resume(throwing: err); return }
                        guard let user else {
                            c.resume(throwing: NSError(domain: "UserSession", code: -2, userInfo: [NSLocalizedDescriptionKey: "No previous Google user"]))
                            return
                        }
                        c.resume(returning: user)
                    }
                }
                // Firebase’e credential ile bağla
                if let idToken = gUser.idToken?.tokenString {
                    let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: gUser.accessToken.tokenString)
                    _ = try await auth.signIn(with: credential) // listener gerisini halleder
                    return
                }
            } catch {
                // sessiz geç
            }
        }

        // 2) Email/Şifre auto-login (senin mevcut yöntem)
        let savedEmail = userPrefs.savedEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let savedPass = (keychain.loadPassword() ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !savedEmail.isEmpty, !savedPass.isEmpty else { return }
        do {
            // Mevcut servisle de yapılabilir; basitçe Firebase ile:
            _ = try await auth.signIn(withEmail: savedEmail, password: savedPass) // listener tetikler
        } catch {
            // başarısızsa sessizce LoginView’a düş
        }
    }

    // MARK: - Sign out (auto-login döngüsünü kır)
    func logout() {
        do { try auth.signOut() } catch { /* ignore */ }
        GIDSignIn.sharedInstance.signOut()
        UserDefaults.standard.set(true, forKey: skipKey) // bir sonraki açılışta auto-login denemesin
        self.currentUser = nil
        self.userInfoModel = nil
        try? Auth.auth().signOut()
    }

    func clearSkipAutoLoginFlag() {
        UserDefaults.standard.set(false, forKey: skipKey)
    }

    // MARK: - Firestore userInfo (senin modele göre)
    private func fetchOrCreateUserInfo(userId: String, name: String, email: String) async throws -> UserInfoModel {
        let doc = db.collection("users").document(userId).collection("userInfo").document("userInfo")
        let snap = try await doc.getDocument()
        if let data = snap.data(), let info = UserInfoModel(dictionary: data) {
            return info
        }

        // Yoksa varsayılan oluştur
        let newInfo = UserInfoModel(
            userId: userId,
            email: email,
            name: name,
            lastname: "",
            dailyTarget: 100, // kendi Constants’ına göre güncelle
            dailyScore: 0
        )
        try await doc.setData(newInfo.toDictionary(), merge: true)
        return newInfo
    }
}

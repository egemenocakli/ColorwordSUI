//
//  AppDelegate.swift
//  ColorwordSUI
//
//  Created by Emre Ocaklı on 21.10.2024.
//

import FirebaseCore
import UIKit
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        // 1) Firebase
        FirebaseApp.configure()

        // 2) Bildirim izinleri
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        application.registerForRemoteNotifications()

        // 3) FCM delegate
        Messaging.messaging().delegate = self

        return true
    }

    // APNs device token → FCM'e ver
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // FCM token yenilendi / oluştu
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Token'i sunucuya gönder vs.
        print("FCM token:", fcmToken ?? "nil")
    }

    // Arkaplan bildirimi (opsiyonel)
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
    }
}

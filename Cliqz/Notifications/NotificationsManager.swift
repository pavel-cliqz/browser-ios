//
//  NotificationsManager.swift
//  Client
//
//  Created by Pavel Kirakosyan on 14.05.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationsManager {
    func requestAuthorization() {
        if #available(iOS 12.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.provisional, .alert, .sound]) { _,_  in }
        }
    }
    
    func scheduleNotifications() {
        if #available(iOS 12.0, *) {
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { (setting) in
                if setting.authorizationStatus == .provisional || setting.authorizationStatus == .authorized {
                    self.removeAllScheduledNotificaions()
                    
                    let center = UNUserNotificationCenter.current()
                    let requests = self.createNotificationReqeusts()
                    for request in requests {
                        center.add(request) { (error) in
                            if let error = error {
                                print("error \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    print("notification authorization status - \(setting.authorizationStatus.rawValue)")
                }
            }
        }
    }
    
    func removeAllScheduledNotificaions() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    // MARK: private methods
    
    private func createNotificationReqeusts() -> [UNNotificationRequest] {
        let currentSubscription = SubscriptionController.shared.getCurrentSubscription()
        switch currentSubscription {
        case .limited, .trial(_):
            return self.createSubscriptionReminderRequests()
        default:
            return []
        }
    }
    
    private func createSubscriptionReminderRequests() -> [UNNotificationRequest] {
        return []
    }
    
}

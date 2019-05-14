//
//  NotificationsManager.swift
//  Client
//
//  Created by Pavel Kirakosyan on 14.05.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import UserNotifications
import Shared

enum NotificationType: String {
    case subscriptionReminder = "subscriptionReminder"
}

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
        guard let installationDate = DeviceInfo.appInstallationDate() else  {
            return []
        }
        var requests:[UNNotificationRequest] = []
        for i in self.subscriptionReminderDays {
            if let scheduleDate = self.createScheduleDate(byAdding: i, to: installationDate), let request = self.createSubscriptionReminderRequest(triggerDate: scheduleDate) {
                requests.append(request)
            }
        }
        
        return requests
    }
    
    private func createSubscriptionReminderRequest(triggerDate: Date) -> UNNotificationRequest? {
        guard triggerDate.compare(Date()) == .orderedDescending else {
            return nil
        }
        
        let content = UNMutableNotificationContent()
        content.body = "Limited time offer: 50% off for Lumen protection + VPN. Code: LUMEN2019" //TODO NSLocalizedString("<#T##key: String##String#>", comment: "")
        content.title = "Hurry up!" // TODO:
        
        let calendar = Calendar.current
        let triggerDateComponents = calendar.dateComponents([.day, .year, .month, .timeZone, .hour, .second, .minute, .calendar], from: triggerDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        return UNNotificationRequest(identifier: NotificationType.subscriptionReminder.rawValue, content: content, trigger: trigger)
    }
    
    private func createScheduleDate(byAdding days: Int, to date: Date) -> Date? {
        let calendar = Calendar.current
        let triggerDate = calendar.date(byAdding: .day, value: days, to: date)
        var dateComponent = calendar.dateComponents([.day, .year, .month, .timeZone, .calendar], from: triggerDate!)
        dateComponent.hour = 9
        return calendar.date(from: dateComponent)
    }
    
    private var subscriptionReminderDays: [Int] {
        return [3,7,9,20]
    }
}

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
        self.removeAllScheduledNotificaions()
    }
    
    func removeAllScheduledNotificaions() {
        
    }
}

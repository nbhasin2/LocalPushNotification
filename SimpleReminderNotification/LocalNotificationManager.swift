//
//  LocalNotificationManager.swift
//  SimpleReminderNotification
//
//  Created by Nishant Bhasin on 2021-03-14.
//

import Foundation
import UserNotifications

enum NotificationPermission {
    case authorized
    case denied
    case unknown
    case notAsked
}

class LocalNotificationManager {
    let center = UNUserNotificationCenter.current()
    
    // Check permission status
    func checkIfRegistered(completion: @escaping (NotificationPermission) -> Void) {
        center.getNotificationSettings { permission in
            switch permission.authorizationStatus {
            case .authorized:
                print("Authorized")
                completion(.authorized)
            case .denied:
                print("Denied")
                completion(.denied)
            case .ephemeral:
                print("Temporary notification for App Clips")
                completion(.unknown)
            case .notDetermined:
                print("No permission asked")
                completion(.notAsked)
            case .provisional:
                print("Authorized to post non-interruptive notification ")
                completion(.authorized)
            default:
                print("unknown")
                completion(.unknown)
            }
        }
    }
    
    // Ask for permission to send push notification
    func registerLocal(completion: @escaping (Bool, Error?) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            completion(granted, error)
        }
    }
    
    // Schedule push notification to be sent
    func schedule(title: String, body: String, id: String, date: Date, repeats: Bool = false) {
        let units: Set<Calendar.Component> = [.minute, .hour, .day, .month, .year]
        let dateComponents = Calendar.current.dateComponents(units, from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        schedule(title: title, body: body, id: id, trigger: trigger)
    }
    
    func schedule(title: String, body: String, id: String, interval: TimeInterval, repeats: Bool = false) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: repeats)
        schedule(title: title, body: body, id: id, trigger: trigger)
    }
    
    private func schedule(title: String, body: String, id: String, trigger: UNNotificationTrigger) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.sound = UNNotificationSound.default
        let trigger = trigger
        let request = UNNotificationRequest(identifier: id, content: notificationContent, trigger: trigger)
        center.add(request)
    }
    
    // Remove push notification
    func removeAllPendingNotifications() {
        center.removeAllPendingNotificationRequests()
    }

    func removePendingNotificationsWithId(ids: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    func removeNotificationsWithId(ids: [String]) {
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }
    
    // Find push notifications
    func findDeliveredNotifications(completion: @escaping ([UNNotification]) -> Void) {
        center.getDeliveredNotifications { notificationList in
            completion(notificationList)
        }
    }
    
    func findDeliveredNotificationForId(id: String, completion: @escaping (UNNotification?) -> Void) {
        findDeliveredNotifications { notificationList in
            let notification = notificationList.filter { notification -> Bool in
                notification.request.identifier == id
            }.first
            completion(notification)
        }
    }
    
    func findPendingNotificationRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
        center.getPendingNotificationRequests { notificationRequestList in
            completion(notificationRequestList)
        }
    }
    
    func findPendingNotificationForId(id: String, completion: @escaping (UNNotificationRequest?)->Void) {
        findPendingNotificationRequests { notificationRequestList in
            let notificationRequest = notificationRequestList.filter { request -> Bool in
                request.identifier == id
            }.first
            completion(notificationRequest)
        }
    }
}

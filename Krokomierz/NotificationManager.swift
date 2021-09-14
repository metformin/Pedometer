//
//  NotificationManager.swift
//  Krokomierz
//
//  Created by Darek on 08/08/2021.
//

import Foundation
import NotificationCenter
import Combine


class NotificationManager{
    let userNotificationCenter = UNUserNotificationCenter.current()

    func requestAuth() -> Future<Bool,Never>{
        Future { [weak self] promise in
            self?.userNotificationCenter
                .requestAuthorization(options: [.alert,.badge,.sound]) { granted, _ in
                    promise(.success(granted))
                }
        }
    }
    
    func sendNotification(){
        
        userNotificationCenter.getNotificationSettings { settings in
            print(settings)
        }
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Podsumowanie dnia gotowe!"
        notificationContent.body = "Pokonałeś XXX kroków z zakładanych YYY!"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "daySummaryNotification", content: notificationContent, trigger: trigger)
        
        userNotificationCenter.add(request) { err in
            if let err = err {
                print("Error notification center", err)
            }
        }
    }
    func removeNotification(){
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: ["daySummaryNotification"])
    }
    func getPendingNotification(){
        userNotificationCenter.getPendingNotificationRequests { pending in
            print(pending)
        }
    }
    func checkIfNotificationIsEnabled() -> Future<Bool,Never> {
        Future { [weak self] promise in
            self?.userNotificationCenter.getPendingNotificationRequests { pending in
                if pending.isEmpty{
                    promise(.success(false))
                } else {
                    promise(.success(true))
                }
            }
        }

    }
}

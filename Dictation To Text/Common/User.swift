//
//  User.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/17/21.
//

import Foundation

final class User: NSObject {
    
    static let shared = User()

    var subscriptionInfo: PurchasesInfo?

    private var hasSubscription: Bool {
        return subscriptionInfo?.isActive ?? false
    }

    var isPremium: Bool {
        return hasSubscription || isTrialModeActive
    }

    var installDate: Date {
        let date = UserDefaults.standard.value(forKey: "installDate") as? Date
        if let date = date {
            return date
        } else {
            let now = Date()
            UserDefaults.standard.setValue(now, forKey: "installDate")
            return now
        }
    }

    private var trialTimeDays = 7

    var trialEndDate: Date {
        return Calendar.current.date(byAdding: .day, value: trialTimeDays, to: installDate) ?? Date()
    }

    var isTrialModeActive: Bool {
        let now = Date()
        return trialEndDate >= now
    }
}

//
//  AdCommon.swift
//  Drum Pad Beat Maker - Music Production
//
//  Created by Artem Sherbachuk on 1/26/21.
//

import AppTrackingTransparency
import FacebookCore

func checkIfShouldRequestIDFA(completion:@escaping () -> Void) {
    if #available(iOS 14.5, *) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            DispatchQueue.main.async {
                FacebookCore.Settings.setAdvertiserTrackingEnabled(status == .authorized)
                completion()
            }
        })
    } else {
        FacebookCore.Settings.setAdvertiserTrackingEnabled(true)
        completion()
    }
}

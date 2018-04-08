//
//  Tracker.swift
//  DoneList
//
//  Created by Khanh Pham on 21/3/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import Foundation
import Fabric
import Crashlytics
import Firebase

class Tracker {

    static let shared = Tracker()

    func setup() {
        Fabric.with([Crashlytics.self])
    }

    func track(_ name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
        Answers.logCustomEvent(withName: name, customAttributes: parameters)
    }

    func trackLogIn(method: String, userID: String?, customAttributes: [String: Any]?) {
        Analytics.setUserID(userID)
        for item in customAttributes ?? [:] {
            var val: String? = item.value as? String
            if val == nil {
                val = "\(item.value)"
            }
            if let val = val {
                Analytics.setUserProperty(val, forName: item.key)
            }
        }

        Answers.logLogin(withMethod: method, success: NSNumber(value: true),
                         customAttributes: customAttributes)
    }

    func clear() {
        Analytics.setUserID(nil)
    }

}

struct TrackerEvent {
    static var error: String { return "Error" }
}

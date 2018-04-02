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
        FirebaseApp.configure()
    }

    func track(_ name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
        Answers.logCustomEvent(withName: name, customAttributes: parameters)
    }
}

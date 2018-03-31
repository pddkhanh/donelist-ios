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


protocol TrackerType {

    func track(_ name: String)
}

class Tracker: TrackerType {

    static let shared = Tracker()

    func setup() {
        Fabric.with([Crashlytics.self])
    }

    func track(_ name: String) {

    }
}

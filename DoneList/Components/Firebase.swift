//
//  Firebase.swift
//  DoneList
//
//  Created by Khanh Pham on 7/4/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import Foundation
import Firebase

class Firebase {
    static func setup() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
    }
}

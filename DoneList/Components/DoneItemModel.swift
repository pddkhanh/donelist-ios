//
//  DoneItemModel.swift
//  DoneList
//
//  Created by Khanh Pham on 30/3/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import Foundation

public struct DoneItemModel {

    public var id: String
    public var title: String?
    public var created: Date?
    public var updated: Date?

    public init(id: String = UUID().uuidString, title: String?, created: Date? = Date(), updated: Date? = Date()) {
        self.id = id
        self.title = title
        self.created = created
        self.updated = updated
    }

}


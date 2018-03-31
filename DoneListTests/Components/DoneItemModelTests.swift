//
//  DoneItemModelTests.swift
//  DoneListTests
//
//  Created by Khanh Pham on 30/3/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import XCTest
import Nimble
@testable import DoneList

class DoneItemModelTests: XCTestCase {

    func testInit() {
        let created = Date()
        let updated = Date().addingTimeInterval(60)
        let model = DoneItemModel(id: "t", title: "test", created: created, updated: updated)
        expect(model.id).to(equal("t"))
        expect(model.title).to(equal("test"))
        expect(model.created).to(equal(created))
        expect(model.updated).to(equal(updated))
    }
}

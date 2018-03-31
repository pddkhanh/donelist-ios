//
//  DoneItemsRepositoryTests.swift
//  DoneListTests
//
//  Created by Khanh Pham on 30/3/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import XCTest
import Nimble
import RxSwift
import RxBlocking

@testable import DoneList

class DoneItemsRepositoryTests: XCTestCase {

    var sut: DoneItemsRepository!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        sut = DoneItemsRepository()
        disposeBag = DisposeBag()
    }

    func testShouldStartWithNoItems() {
        var items: [DoneItemModel]!
        expectToNotThrowError {
            items = try self.sut.items().toBlocking(timeout: 0.5)
                .first()
        }
        expect(items).toNot(beNil())
        if items == nil { return }

        expect(items).to(beEmpty())
    }

    func testSaveShouldWorkCorrectly() {
        let item0 = DoneItemModel(id: "", title: "t0")
        let item1 = DoneItemModel(id: "1", title: "t1")
        let item2 = DoneItemModel(id: "2", title: "t2")
        let item3 = DoneItemModel(id: "1", title: "t1u")

        sut.save(item: item0)
        sut.save(item: item1)
        sut.save(item: item2)
        sut.save(item: item3)

        var items: [DoneItemModel]!
        expectToNotThrowError {
            items = try self.sut.items().take(1).toBlocking(timeout: 0.5)
                .first()
        }
        expect(items).to(haveCount(2))
        let updatedItem = items.first { $0.id == "1" }
        expect(updatedItem?.updated).toNot(beNil())
        expect(updatedItem?.title).to(equal("t1u"))
    }

    func testRemoveItem() {
        let item1 = DoneItemModel(id: "1", title: "t1")
        let item2 = DoneItemModel(id: "2", title: "t2")

        sut.save(item: item1)
        sut.save(item: item2)
        sut.remove(itemId: item2.id)
        sut.remove(itemId: item2.id)

        var items: [DoneItemModel]!
        expectToNotThrowError {
            items = try self.sut.items().take(1).toBlocking(timeout: 0.5)
                .first()
        }
        expect(items).to(haveCount(1))
    }
}

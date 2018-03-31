//
//  DoneItemsRepository.swift
//  DoneList
//
//  Created by Khanh Pham on 30/3/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import Foundation
import RxSwift

public class DoneItemsRepository {

    private var itemsSubject = BehaviorSubject<[DoneItemModel]>(value: [])

    public func items() -> Observable<[DoneItemModel]> {
        return itemsSubject
    }

    public func save(item: DoneItemModel) {
        if item.id.isEmpty { return }

        var items: [DoneItemModel]
        do {
            items = try itemsSubject.value()
        } catch {
            logError(error.localizedDescription)
            items = []
        }
        if let idx = items.index(where: { $0.id == item.id }) {
            var existed = items[idx]
            existed.merge(from: item)
            existed.updated = Date()
            items[idx] = existed
            logDebug("Update item")
            itemsSubject.onNext(items)
        } else {
            items.append(item)
            logDebug("Add item")
            itemsSubject.onNext(items)
        }
    }

    public func remove(itemId: String) {
        if itemId.isEmpty { return }

        do {
            var items = try itemsSubject.value()
            if let idx = items.index(where: { $0.id == itemId }) {
                items.remove(at: idx)
                itemsSubject.onNext(items)
            }
        } catch {
            logError(error.localizedDescription)
        }

    }

}

extension DoneItemModel {
    mutating func merge(from item: DoneItemModel) {
        title = item.title
        created = item.created
        updated = item.updated
    }
}

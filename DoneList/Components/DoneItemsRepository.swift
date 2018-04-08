//
//  DoneItemsRepository.swift
//  DoneList
//
//  Created by Khanh Pham on 30/3/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseDatabase

public class DoneItemsRepository {

    static let shared = DoneItemsRepository()

    private var ref: DatabaseReference?
    private var currentObserver: UInt?
    private var itemsSubject = BehaviorSubject<[DoneItemModel]>(value: [])

    private init() {}

    public func loadData(userId: String) {
        if let ref = self.ref, let observer = currentObserver {
            logDebug("removeAllObservers")
            ref.removeObserver(withHandle: observer)
            self.ref = nil
            self.currentObserver = nil
        }

        let ref = Database.database().reference().child(userId).child("items")
        self.ref = ref
        currentObserver = ref
            .queryOrdered(byChild: "updated")
            .observe(DataEventType.value) { [weak self] (snapshot) in
                guard let weakSelf = self else { return }
                logDebug("items changed: \(snapshot.childrenCount)")
                let parseItems = snapshot.children.compactMap({ (childObj) -> DoneItemModel? in
                    guard let child = childObj as? DataSnapshot else { return nil }
                    guard let childValues = child.value as? [String: Any] else { return nil }

                    var created: Date?
                    if let interval = childValues["created"] as? TimeInterval {
                        created = Date(timeIntervalSince1970: interval)
                    }

                    var updated: Date?
                    if let interval = childValues["updated"] as? TimeInterval {
                        updated = Date(timeIntervalSince1970: interval)
                    }

                    return DoneItemModel(id: child.key,
                                         title: childValues["title"] as? String,
                                         created: created,
                                         updated: updated)
                })

                weakSelf.itemsSubject.onNext(parseItems.reversed())
        }

    }

    private func setupRef(userId: String) {
        let ref = Database.database().reference().child(userId).child("items")
        self.ref = ref
        currentObserver = ref
            .queryOrdered(byChild: "updated")
            .observe(DataEventType.value) { [weak self] (snapshot) in
                guard let weakSelf = self else { return }
                logDebug("items changed: \(snapshot.childrenCount)")
                let parseItems = snapshot.children.compactMap({ (childObj) -> DoneItemModel? in
                    guard let child = childObj as? DataSnapshot else { return nil }
                    guard let childValues = child.value as? [String: Any] else { return nil }

                    var created: Date?
                    if let interval = childValues["created"] as? TimeInterval {
                        created = Date(timeIntervalSince1970: interval)
                    }

                    var updated: Date?
                    if let interval = childValues["updated"] as? TimeInterval {
                        updated = Date(timeIntervalSince1970: interval)
                    }

                    return DoneItemModel(id: child.key,
                                         title: childValues["title"] as? String,
                                         created: created,
                                         updated: updated)
                })

                weakSelf.itemsSubject.onNext(parseItems)
        }
    }

    public func items() -> Observable<[DoneItemModel]> {
        return itemsSubject
    }

    public func save(item: DoneItemModel) {
        guard let ref = ref, item.id.isNotEmpty else { return }
        var updated = item
        updated.updated = Date()
        ref.child(updated.id)
            .setValue(updated.dictionary) { (error, _) in
                if let err = error {
                    logError("Save item failed: \(err.localizedDescription)")
                    Tracker.shared.track(TrackerEvent.error, parameters: [
                        "context": "add_item",
                        "localizedDescription": err.localizedDescription
                        ])
                } else {
                    logDebug("Save item success.")
                }
            }
    }

    public func remove(itemId: String) {
        guard let ref = ref, itemId.isNotEmpty else { return }
        ref.child(itemId).removeValue { (error, _) in
            if let err = error {
                logError("Remove item failed: \(err.localizedDescription)")
                Tracker.shared.track(TrackerEvent.error, parameters: [
                    "context": "remove_item",
                    "itemId": "itemId",
                    "localizedDescription": err.localizedDescription
                    ])
            } else {
                logDebug("Remove item \(itemId) success.")
            }
        }
    }

}

extension DoneItemModel {
    mutating func merge(from item: DoneItemModel) {
        title = item.title
        created = item.created
        updated = item.updated
    }

    var dictionary: [String: Any] {
        var rs: [String: Any] = [
            "id": id,
        ]

        if let title = title {
            rs["title"] = title
        }
        if let created = created?.timeIntervalSince1970 {
            rs["created"] = created
        }
        if let updated = updated?.timeIntervalSince1970 {
            rs["updated"] = updated
        }
        return rs
    }

}

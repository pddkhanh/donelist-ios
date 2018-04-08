//
//  App.swift
//  DoneList
//
//  Created by Khanh Pham on 7/4/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class App {

    static func load() -> Completable {
        let loadUser: Single<MyUser>
        if let user = Authenticator.shared.currentUser {
            logDebug("Already log in: \(user.uid)")
            loadUser = .just(user)
        } else {
            loadUser = Authenticator.shared.signInAnonymously()
                .flatMap({ (user) -> PrimitiveSequence<SingleTrait, MyUser> in
                    logDebug("Log in anonymous: \(user.uid)")
                    Tracker.shared.trackLogIn(method: "Anonymous", userID: user.uid, customAttributes: nil)
                    return .just(user)
                })
                .catchError({ (error) -> PrimitiveSequence<SingleTrait, MyUser> in
                    Tracker.shared.track(TrackerEvent.error, parameters: [
                        "context": "sign_in_anonymous",
                        "error": error.localizedDescription
                        ])
                    return .error(error)
                })
        }
        return loadUser
            .flatMap { (user) -> PrimitiveSequence<SingleTrait, MyUser> in
                DoneItemsRepository.shared.loadData(userId: user.uid)
                return .just(user)
            }
            .asCompletable()

    }

}

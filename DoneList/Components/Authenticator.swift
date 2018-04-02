//
//  Authenticator.swift
//  DoneList
//
//  Created by Khanh Pham on 2/4/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import Foundation
import FirebaseAuth
import RxSwift

class Authenticator {

    static let shared = Authenticator()

    var currentUser: MyUser? {
        return Auth.auth().currentUser?.myUser
    }

    func signInAnonymously() -> Single<MyUser> {
        return Auth.auth().rx.signInAnonymously()
            .map { $0.myUser }
    }

}

protocol MyUserInfo {
    var uid: String? { get }
    var email: String? { get }
    var displayName: String? { get }
}

struct MyUser: MyUserInfo {

    var uid: String? { return user.uid }

    var email: String? { return user.email }

    var displayName: String? { return user.displayName }

    private var user: User

    init(user: User) {
        self.user = user
    }
}

extension User {
    var myUser: MyUser {
        return MyUser(user: self)
    }
}

extension Reactive where Base: Auth {
    func signInAnonymously() -> Single<User> {
        return Single.create(subscribe: { [base] (single) -> Disposable in
            base.signInAnonymously(completion: { (user, error) in
                if let user = user {
                    single(.success(user))
                } else if let error = error {
                    single(.error(error))
                } else {
                    single(.error(MyError.unexpected("Auth: Empty response")))
                }
            })
            return Disposables.create()
        })
    }
}

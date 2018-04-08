//
//  Core.swift
//  DoneList
//
//  Created by Khanh Pham on 2/4/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import Foundation

enum MyError: Error {
    case unexpected(String)
}

extension MyError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unexpected(let msg):
            return msg
        }
    }
}

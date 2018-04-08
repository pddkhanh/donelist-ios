//
//  Foundation+Extension.swift
//
//
//  Created by Khanh Pham on 12/1/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import Foundation

// MARK: - Emptiable

protocol StringWrapper {
    var asString: String { get }
}

extension String: StringWrapper {
    var asString: String { return self }
}

public protocol Emptiable {
    var isEmpty: Bool { get }
}

public extension Emptiable {
    public var isNotEmpty: Bool { return !isEmpty }
}

extension String: Emptiable { }
extension Array: Emptiable { }

public extension Optional where Wrapped: Emptiable {
    public var isNilOrEmpty: Bool {
        guard let value = self else { return true }
        return value.isEmpty
    }

    public var hasElements: Bool {
        return !isNilOrEmpty
    }
}

// MARK: - ISO8601

public extension Formatter {
    public static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}

public extension Date {
    public var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

public extension String {
    public var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}

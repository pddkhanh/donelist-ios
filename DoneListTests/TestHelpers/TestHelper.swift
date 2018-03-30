//
//  TestHelper.swift
//  DoneListTests
//
//  Created by Khanh Pham on 30/3/18.
//  Copyright © 2018 Khanh Pham. All rights reserved.
//

import Foundation
import Nimble

func ==<Element: Equatable> (lhs: [[Element]], rhs: [[Element]]) -> Bool {
    let isEqual = lhs.elementsEqual(rhs) { (left, right) -> Bool in
        return left == right
    }
    return isEqual
}

//public func beNilOrEmpty() -> Predicate<String> {
//    return Predicate.simpleNilable("be nil or empty") { actualExpression in
//        let actualString = try actualExpression.evaluate()
//        return PredicateStatus(bool: actualString == nil || NSString(string: actualString!).length  == 0)
//    }
//}

public func beNilOrEmpty<S: Sequence>() -> Predicate<S> {
    return Predicate.simpleNilable("be nil orempty") { actualExpression in
        let actualSeq = try actualExpression.evaluate()
        if actualSeq == nil {
            return .fail
        }
        var generator = actualSeq!.makeIterator()
        return PredicateStatus(bool: generator.next() == nil)
    }
}

public func expectToNotThrowError(_ file: FileString = #file, line: UInt = #line, _ expression: @escaping () throws -> Void) {
    expect(file, line: line, expression: expression).toNot(throwError())
}

public func expectToThrowError(_ file: FileString = #file, line: UInt = #line, _ expression: @escaping () throws -> Void) {
    expect(file, line: line, expression: expression).to(throwError())
}

public final class TestHelper: NSObject {
    public static func loadJsonData(forResource resource: String) throws -> Data {
        guard let resFileUrl = Bundle(for: TestHelper.classForCoder())
            .url(forResource: resource, withExtension: "json") else {
                throw NSError(domain: "Test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Resource not found"])
        }
        return try Data(contentsOf: resFileUrl)
    }
}

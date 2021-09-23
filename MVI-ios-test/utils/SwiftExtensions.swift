//
//  SwiftExtensions.swift
//  MVI-ios-test
//
//  Created by ziryanov on 22.09.2021.
//

import Foundation

struct NotEmptyDictonary<Key: CaseIterable & Hashable, Value> {
    private var values: [Key: Value]
    init(initial: Value) {
        values = Dictionary(uniqueKeysWithValues: Key.allCases.map { ($0, initial) })
    }

    subscript(key: Key) -> Value {
        get {
            return values[key]!
        }
        set {
            values[key] = newValue
        }
    }
}

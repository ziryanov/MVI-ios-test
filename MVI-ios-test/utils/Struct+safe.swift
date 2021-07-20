//
//  Dictionary+safe.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation

public extension Dictionary where Key == String {

    subscript(keyPath components: [String]) -> Any? {
        guard !components.isEmpty else { return nil }
        var comps = components
        let first = comps.removeFirst()
        if comps.isEmpty {
            return self[components[0]]
        } else {
            if let dict = self[first] as? [String: Any] {
                return dict[keyPath: comps]
            } else {
                return nil
            }
        }
    }
    
    subscript(keyPath keyPath: String) -> Any? {
        let components = keyPath.components(separatedBy: ".")
        return self[keyPath: components]
    }
}

public extension Array {
    subscript(safe index: Int?) -> Element? {
        guard let index = index, index < count else { return nil }
        return self[index]
    }
}

//
//  UserDefault.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation

@propertyWrapper
public class UserDefault<T> {
    let key: String

    public init(_ key: String) {
        self.key = key
    }

    public var wrappedValue: T? {
        get {
            return UserDefaults.standard.object(forKey: key) as? T
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
            UserDefaults.standard.synchronize()
        }
    }
}

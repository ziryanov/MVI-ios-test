//
//  WrappingCondition.swift
//  MVI-ios-test
//
//  Created by ziryanov on 19.07.2021.
//

import Foundation

public protocol WrappingConditionProtocol {
    func shouldWrap(target: Any, name: String?, standalone: Bool) -> Bool
}

public enum WrappingCondition: WrappingConditionProtocol {
    case always
    
    public func shouldWrap(target: Any, name: String?, standalone: Bool) -> Bool {
        switch self {
        case .always:
            return true
        }
    }
}

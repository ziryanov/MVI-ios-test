//
//  MiddlewareConfiguration.swift
//  MVI-ios-test
//
//  Created by ziryanov on 19.07.2021.
//

import Foundation

public typealias ConsumerMiddlewareFactory = () -> MiddlewareProtocol

public class MiddlewareConfiguration {
    private let condition: WrappingConditionProtocol
    private let factories: [ConsumerMiddlewareFactory]
    
    public convenience init(condition: WrappingConditionProtocol, factory: @escaping ConsumerMiddlewareFactory) {
        self.init(condition: condition, factories: [factory])
    }
    
    public init(condition: WrappingConditionProtocol, factories: [ConsumerMiddlewareFactory]) {
        self.condition = condition
        self.factories = factories
    }
    
    func applyOn<T>(consumerToWrap: Consumer<T>, targetToCheck: Any, name: String?, standalone: Bool) -> Consumer<T> {
        guard condition.shouldWrap(target: targetToCheck, name: name, standalone: standalone) else { return consumerToWrap }
        return factories.reduce(consumerToWrap, { MiddlewareWrapper($0, middleware: $1()) })
    }
}

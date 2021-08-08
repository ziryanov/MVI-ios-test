//
//  Consumer+middleware.swift
//  MVI-ios-test
//
//  Created by ziryanov on 17.07.2021.
//

import Foundation

//extension Consumer {
//    func wrapWithMiddleware(standalone: Bool = true, name: String? = nil, postfix: String? = nil, wrapperOf: Any? = nil) -> Consumer<T> {
//        let target = wrapperOf ?? self
//        var current = self
//
//        for config in Middlewares.configurations {
//            current = config.applyOn(consumerToWrap: current, targetToCheck: target, name: name, standalone: standalone)
//        }
//
//        if let current = current as? MiddlewareWrapper, standalone {
//            return StandaloneMiddleware(wrapped: current, name: name ?? wrapperOf.let { String(describing: $0) }, postfix: postfix)
//        }
//
//        return current
//    }
//}

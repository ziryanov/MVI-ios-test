//
//  Middleware.swift
//  MVI-ios-test
//
//  Created by ziryanov on 18.07.2021.
//

import Foundation

//public protocol MiddlewareProtocol {
//    func onBind<Out, In>(_ connection: Connection<Out, In>)
//    func onElement<Out, In>(_ connection: Connection<Out, In>, _ element: In)
//    func onComplete<Out, In>(_ connection: Connection<Out, In>)
//}
//
//class MiddlewareWrapper<In>: Consumer {
//    private let wrapped: Consumer<In>
//    private let middleware: MiddlewareProtocol
//    
//    init(_ wrapped: Consumer<In>, middleware: MiddlewareProtocol) {
//        self.wrapped = wrapped
//        self.middleware = middleware
//    }
//
//    override func accept(_ element: In) {
//        wrapped.accept(element)
//    }
//    
//    private func applyIfMiddleware(_ block: (MiddlewareWrapper) -> Void) {
//        if let wrapped = wrapped as? MiddlewareWrapper {
//            block(wrapped)
//        }
//    }
//    
//    open func onBind<Out>(_ connection: Connection<Out, In>) {
//        middleware.onBind(connection)
//        applyIfMiddleware { $0.onBind(connection) }
//    }
//
//    open func onElement<Out>(_ connection: Connection<Out, In>, _ element: In) {
//        middleware.onElement(connection, element)
//        applyIfMiddleware { $0.onElement(connection, element) }
//    }
//
//    open func onComplete<Out>(_ connection: Connection<Out, In>) {
//        middleware.onComplete(connection)
//        applyIfMiddleware { $0.onComplete(connection) }
//    }
//
//    var innerMost: Consumer<In> {
//        var consumer = wrapped
//        while let parent = consumer as? MiddlewareWrapper {
//            consumer = parent.wrapped
//        }
//        return consumer
//    }
//}

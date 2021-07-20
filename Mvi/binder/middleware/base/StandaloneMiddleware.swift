//
//  StandaloneMiddleware.swift
//  MVI-ios-test
//
//  Created by ziryanov on 19.07.2021.
//

import Foundation

final class StandaloneMiddleware<In>: Consumer<In> {
    
    private let wrappedMiddleware: MiddlewareWrapper<In>
    private let connection: Connection<In, In>
    
    init(wrapped: MiddlewareWrapper<In>, name: String? = nil, postfix: String?) {
        wrappedMiddleware = wrapped
        connection = Connection<In, In>(name: "\(name ?? String(describing: wrapped.innerMost)).\(postfix ?? "input")", to: wrapped)        
        wrappedMiddleware.onBind(connection)
    }
    
    override func accept(_ element: In) {
        wrappedMiddleware.onElement(connection, element)
        wrappedMiddleware.accept(element)
    }
    
    deinit {
        wrappedMiddleware.onComplete(connection)
    }
}

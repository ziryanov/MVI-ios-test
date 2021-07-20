//
//  Binder.swift
//  MVI-ios-test
//
//  Created by ziryanov on 18.07.2021.
//

import Foundation
import Combine

open class Binder {
    private var disposables = [AnyCancellable]()
    private let deinitSignal = PassthroughSubject<Void, Never>()
    
    
    func bind<T>(_ observer: AnyPublisher<T, Never>, to: Consumer<T>, name: String? = nil) {
        bind(observer, to: to, using: { $0 }, name: name)
    }
    
    func bind<Out, In>(_ observer: AnyPublisher<Out, Never>, to: Consumer<In>, using transform: @escaping (Out) -> In?, name: String? = nil) {
        bind(observer, to: to, using: connector(from: transform))
    }
    
    func bind<Out, In>(_ observer: AnyPublisher<Out, Never>, to: Consumer<In>, using connector: @escaping Connector<Out, In>, name: String? = nil) {
        let consumer: Consumer<In>
        if let middleware = to.wrapWithMiddleware(standalone: false, name: name) as? MiddlewareWrapper<In> {
            let connection = Connection(name: name, from: observer, to: to, connector: connector)
            middleware.onBind(connection)
            consumer = middleware
            
            deinitSignal.sink { _ in
                middleware.onComplete(connection)
            }
            .store(in: &disposables)
        } else {
            consumer = to
        }
        
        connector(observer)
            .sink {
                consumer.accept($0)
            }
            .store(in: &disposables)
    }
}

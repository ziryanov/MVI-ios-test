//
//  Connection.swift
//  MVI-ios-test
//
//  Created by ziryanov on 18.07.2021.
//

import Foundation
import RxSwift

//public typealias Connector<Out, In> = (AnyPublisher<Out, Never>) -> AnyPublisher<In, Never>
//
//func connector<Out, In>(from transform: @escaping (Out) -> In?) -> Connector<Out, In> {
//    return { publisher in
//        publisher
//            .compactMap { transform($0) }
//            .eraseToAnyPublisher()
//    }
//}
//
//final public class Connection<Out, In>: CustomStringConvertible {
//    public let name: String?
//    public let from: AnyPublisher<Out, Never>?
//    public let to: Consumer<In>
//    public let connector: Connector<Out, In>?
//
//    init(name: String?, from: AnyPublisher<Out, Never>? = nil, to: Consumer<In>, connector: Connector<Out, In>? = nil) {
//        self.name = name
//        self.from = from
//        self.to = to
//        self.connector = connector
//    }
//
//    public var description: String {
//        return "<\(name ?? "anonymous")> \(from.let { "\($0)" } ?? "?") --> \(to)" + (connector.let { " using " + String(describing: $0)} ?? "")
//    }
//}

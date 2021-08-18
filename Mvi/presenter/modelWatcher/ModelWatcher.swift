//
//  ModelWatcher.swift
//  MVI-ios-test
//
//  Created by ziryanov on 07.08.2021.
//

import Foundation

internal protocol WatchProtocol {
    func apply<Model>(model: Model, old: Model?)
}

public struct Watch<Model, Value: Equatable> {
    private let kp: KeyPath<Model, Value>
    private let block: (Value) -> Void
    public init(_ keyPath: KeyPath<Model, Value>, block: @escaping (Value) -> Void) {
        self.kp = keyPath
        self.block = block
    }
}

extension Watch: WatchProtocol {
    internal func apply<AModel>(model: AModel, old: AModel?) {
        guard let value = (model as? Model)?[keyPath: kp],
        value != (old as? Model)?[keyPath: kp] else { return }
        block(value)
    }
}

public class ModelWatcher<Model> {
    private let tuple: Any
    fileprivate init(tuple: Any) {
        self.tuple = tuple
    }
    
    private var oldModel: Model?
    public func apply(_ model: Model) {
        switch tuple {
        case let value as WatchProtocol:
            value.apply(model: model, old: oldModel)
        case let value as (WatchProtocol, WatchProtocol):
            value.0.apply(model: model, old: oldModel)
            value.1.apply(model: model, old: oldModel)
        case let value as (WatchProtocol, WatchProtocol, WatchProtocol):
            value.0.apply(model: model, old: oldModel)
            value.1.apply(model: model, old: oldModel)
            value.2.apply(model: model, old: oldModel)
        case let value as (WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol):
            value.0.apply(model: model, old: oldModel)
            value.1.apply(model: model, old: oldModel)
            value.2.apply(model: model, old: oldModel)
            value.3.apply(model: model, old: oldModel)
        case let value as (WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol):
            value.0.apply(model: model, old: oldModel)
            value.1.apply(model: model, old: oldModel)
            value.2.apply(model: model, old: oldModel)
            value.3.apply(model: model, old: oldModel)
            value.4.apply(model: model, old: oldModel)
        case let value as (WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol):
            value.0.apply(model: model, old: oldModel)
            value.1.apply(model: model, old: oldModel)
            value.2.apply(model: model, old: oldModel)
            value.3.apply(model: model, old: oldModel)
            value.4.apply(model: model, old: oldModel)
            value.5.apply(model: model, old: oldModel)
        case let value as (WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol):
            value.0.apply(model: model, old: oldModel)
            value.1.apply(model: model, old: oldModel)
            value.2.apply(model: model, old: oldModel)
            value.3.apply(model: model, old: oldModel)
            value.4.apply(model: model, old: oldModel)
            value.5.apply(model: model, old: oldModel)
            value.6.apply(model: model, old: oldModel)
        case let value as (WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol):
            value.0.apply(model: model, old: oldModel)
            value.1.apply(model: model, old: oldModel)
            value.2.apply(model: model, old: oldModel)
            value.3.apply(model: model, old: oldModel)
            value.4.apply(model: model, old: oldModel)
            value.5.apply(model: model, old: oldModel)
            value.6.apply(model: model, old: oldModel)
            value.7.apply(model: model, old: oldModel)
        case let value as (WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol):
            value.0.apply(model: model, old: oldModel)
            value.1.apply(model: model, old: oldModel)
            value.2.apply(model: model, old: oldModel)
            value.3.apply(model: model, old: oldModel)
            value.4.apply(model: model, old: oldModel)
            value.5.apply(model: model, old: oldModel)
            value.6.apply(model: model, old: oldModel)
            value.7.apply(model: model, old: oldModel)
            value.8.apply(model: model, old: oldModel)
        case let value as (WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol):
            value.0.apply(model: model, old: oldModel)
            value.1.apply(model: model, old: oldModel)
            value.2.apply(model: model, old: oldModel)
            value.3.apply(model: model, old: oldModel)
            value.4.apply(model: model, old: oldModel)
            value.5.apply(model: model, old: oldModel)
            value.6.apply(model: model, old: oldModel)
            value.7.apply(model: model, old: oldModel)
            value.8.apply(model: model, old: oldModel)
            value.9.apply(model: model, old: oldModel)
        case let value as (WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol, WatchProtocol):
            value.0.apply(model: model, old: oldModel)
            value.1.apply(model: model, old: oldModel)
            value.2.apply(model: model, old: oldModel)
            value.3.apply(model: model, old: oldModel)
            value.4.apply(model: model, old: oldModel)
            value.5.apply(model: model, old: oldModel)
            value.6.apply(model: model, old: oldModel)
            value.7.apply(model: model, old: oldModel)
            value.8.apply(model: model, old: oldModel)
            value.10.apply(model: model, old: oldModel)
        default:
            break
        }
        oldModel = model
    }
}

@resultBuilder
public struct ModelWatcherBuilder {

    static func buildBlock<Model, C0: Equatable>(_ c0: Watch<Model, C0>) -> ModelWatcher<Model> {
        return .init(tuple: c0)
    }

    static func buildBlock<Model, C0: Equatable, C1: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>) -> ModelWatcher<Model> {
        return .init(tuple: (c0, c1))
    }

    static func buildBlock<Model, C0: Equatable, C1: Equatable, C2: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>) -> ModelWatcher<Model> {
        return .init(tuple: (c0, c1, c2))
    }

    static func buildBlock<Model, C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>) -> ModelWatcher<Model> {
        return .init(tuple: (c0, c1, c2, c3))
    }

    static func buildBlock<Model, C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable, C4: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>, _ c4: Watch<Model, C4>) -> ModelWatcher<Model> {
        return .init(tuple: (c0, c1, c2, c3, c4))
    }

    static func buildBlock<Model, C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable, C4: Equatable, C5: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>, _ c4: Watch<Model, C4>, _ c5: Watch<Model, C5>) -> ModelWatcher<Model> {
        return .init(tuple: (c0, c1, c2, c3, c4, c5))
    }

    static func buildBlock<Model, C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable, C4: Equatable, C5: Equatable, C6: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>, _ c4: Watch<Model, C4>, _ c5: Watch<Model, C5>, _ c6: Watch<Model, C6>) -> ModelWatcher<Model> {
        return .init(tuple: (c0, c1, c2, c3, c4, c5, c6))
    }

    static func buildBlock<Model, C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable, C4: Equatable, C5: Equatable, C6: Equatable, C7: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>, _ c4: Watch<Model, C4>, _ c5: Watch<Model, C5>, _ c6: Watch<Model, C6>, _ c7: Watch<Model, C7>) -> ModelWatcher<Model> {
        return .init(tuple: (c0, c1, c2, c3, c4, c5, c6, c7))
    }

    static func buildBlock<Model, C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable, C4: Equatable, C5: Equatable, C6: Equatable, C7: Equatable, C8: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>, _ c4: Watch<Model, C4>, _ c5: Watch<Model, C5>, _ c6: Watch<Model, C6>, _ c7: Watch<Model, C7>, _ c8: Watch<Model, C8>) -> ModelWatcher<Model> {
        return .init(tuple: (c0, c1, c2, c3, c4, c5, c6, c7, c8))
    }

    static func buildBlock<Model, C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable, C4: Equatable, C5: Equatable, C6: Equatable, C7: Equatable, C8: Equatable, C9: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>, _ c4: Watch<Model, C4>, _ c5: Watch<Model, C5>, _ c6: Watch<Model, C6>, _ c7: Watch<Model, C7>, _ c8: Watch<Model, C8>, _ c9: Watch<Model, C9>) -> ModelWatcher<Model> {
        return .init(tuple: (c0, c1, c2, c3, c4, c5, c6, c7, c8, c9))
    }

    static func buildBlock<Model, C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable, C4: Equatable, C5: Equatable, C6: Equatable, C7: Equatable, C8: Equatable, C9: Equatable, C10: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>, _ c4: Watch<Model, C4>, _ c5: Watch<Model, C5>, _ c6: Watch<Model, C6>, _ c7: Watch<Model, C7>, _ c8: Watch<Model, C8>, _ c9: Watch<Model, C9>, _ c10: Watch<Model, C10>) -> ModelWatcher<Model> {
        return .init(tuple: (c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10))
    }
}

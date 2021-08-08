//
//  ModelWatcher.swift
//  MVI-ios-test
//
//  Created by ziryanov on 07.08.2021.
//

import Foundation

protocol WatchProtocol {
    func apply<Model>(model: Model, old: Model?)
}

public class ModelWatcher<Model> {
    public struct Watch<Value: Equatable>: WatchProtocol {
        private let kp: KeyPath<Model, Value>
        private let block: (Value) -> Void
        init(_ keyPath: KeyPath<Model, Value>, block: @escaping (Value) -> Void) {
            self.kp = keyPath
            self.block = block
        }
        
        internal func apply<AModel>(model: AModel, old: AModel?) {
            guard let value = (model as? Model)?[keyPath: kp] else { return }
            guard value != (old as? Model)?[keyPath: kp] else { return }
            block(value)
        }
    }

    public struct OnlyOnce: WatchProtocol {
        private let block: (Model) -> Void
        init(_ block: @escaping (Model) -> Void) {
            self.block = block
        }
        
        internal func apply<AModel>(model: AModel, old: AModel?) {
            guard old == nil, let model = model as? Model else { return }
            block(model)
        }
    }

    private let children: [WatchProtocol]
    fileprivate init(children: [WatchProtocol]) {
        self.children = children
    }
    
    private var oldModel: Model?
    public func apply(_ model: Model) {
        children.forEach { $0.apply(model: model, old: oldModel) }
        oldModel = model
    }
}

@resultBuilder
public struct ModelWatcherBuilder<Model> {
    static func buildBlock(_ components: WatchProtocol...) -> ModelWatcher<Model> {
        return .init(children: components)
    }
//    static func buildBlock<C0: Equatable>(_ c0: Watch<Model, C0>) -> ModelWatcher<Model> {
//        return .init(children: [c0])
//    }
//
//    static func buildBlock<C0: Equatable, C1: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>) -> ModelWatcher<Model> {
//        return .init(children: [c0, c1])
//    }
//
//    static func buildBlock<C0: Equatable, C1: Equatable, C2: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>) -> ModelWatcher<Model> {
//        return .init(children: [c0, c1, c2])
//    }
//
//    static func buildBlock<C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>) -> ModelWatcher<Model> {
//        return .init(children: [c0, c1, c2, c3])
//    }
//
//    static func buildBlock<C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable, C4: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>, _ c4: Watch<Model, C4>) -> ModelWatcher<Model> {
//        return .init(children: [c0, c1, c2, c3, c4])
//    }
//
//    static func buildBlock<C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable, C4: Equatable, C5: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>, _ c4: Watch<Model, C4>, _ c5: Watch<Model, C5>) -> ModelWatcher<Model> {
//        return .init(children: [c0, c1, c2, c3, c4, c5])
//    }
//
//    static func buildBlock<C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable, C4: Equatable, C5: Equatable, C6: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>, _ c4: Watch<Model, C4>, _ c5: Watch<Model, C5>, _ c6: Watch<Model, C6>) -> ModelWatcher<Model> {
//        return .init(children: [c0, c1, c2, c3, c4, c5, c6])
//    }
//
//    static func buildBlock<C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable, C4: Equatable, C5: Equatable, C6: Equatable, C7: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>, _ c4: Watch<Model, C4>, _ c5: Watch<Model, C5>, _ c6: Watch<Model, C6>, _ c7: Watch<Model, C7>) -> ModelWatcher<Model> {
//        return .init(children: [c0, c1, c2, c3, c4, c5, c6, c7])
//    }
//
//    static func buildBlock<C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable, C4: Equatable, C5: Equatable, C6: Equatable, C7: Equatable, C8: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>, _ c4: Watch<Model, C4>, _ c5: Watch<Model, C5>, _ c6: Watch<Model, C6>, _ c7: Watch<Model, C7>, _ c8: Watch<Model, C8>) -> ModelWatcher<Model> {
//        return .init(children: [c0, c1, c2, c3, c4, c5, c6, c7, c8])
//    }
//
//    static func buildBlock<C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable, C4: Equatable, C5: Equatable, C6: Equatable, C7: Equatable, C8: Equatable, C9: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>, _ c4: Watch<Model, C4>, _ c5: Watch<Model, C5>, _ c6: Watch<Model, C6>, _ c7: Watch<Model, C7>, _ c8: Watch<Model, C8>, _ c9: Watch<Model, C9>) -> ModelWatcher<Model> {
//        return .init(children: [c0, c1, c2, c3, c4, c5, c6, c7, c8, c9])
//    }
//
//    static func buildBlock<C0: Equatable, C1: Equatable, C2: Equatable, C3: Equatable, C4: Equatable, C5: Equatable, C6: Equatable, C7: Equatable, C8: Equatable, C9: Equatable, C10: Equatable>(_ c0: Watch<Model, C0>, _ c1: Watch<Model, C1>, _ c2: Watch<Model, C2>, _ c3: Watch<Model, C3>, _ c4: Watch<Model, C4>, _ c5: Watch<Model, C5>, _ c6: Watch<Model, C6>, _ c7: Watch<Model, C7>, _ c8: Watch<Model, C8>, _ c9: Watch<Model, C9>, _ c10: Watch<Model, C10>) -> ModelWatcher<Model> {
//        return .init(children: [c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10])
//    }
}

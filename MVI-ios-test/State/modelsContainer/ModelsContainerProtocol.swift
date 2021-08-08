//
//  ModelsContainerProtocol.swift
//  MVI-ios-test
//
//  Created by ziryanov on 08.08.2021.
//

import Foundation

protocol ModelWithId {
    associatedtype ModelId: Hashable
    
    var id: ModelId { get }
//    var modelUuid: UUID { get }
}

protocol ModelsContainerProtocol {
    associatedtype Model: ModelWithId
    typealias ModelId = Model.ModelId
    
    var models: [ModelId: Model] { get set }
}

extension ModelsContainerProtocol {
    func model(with id: ModelId) -> Model? {
        return models[id]
    }

    mutating func updateModel(with id: ModelId, model: Model) {
        models[id] = model
    }

    mutating func updateModels(_ models: [Model]?) {
        models?.forEach {
            self.models[$0.id] = $0
        }
    }
    
    mutating func updateModels(_ models: [(ModelId, Model)]?) {
        models?.forEach {
            self.models[$0.0] = $0.1
        }
    }
}

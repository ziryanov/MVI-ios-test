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
}

protocol ModelsContainerProtocol {
    associatedtype Model: ModelWithId
    typealias ModelId = Model.ModelId
}

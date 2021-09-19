//
//  ModelsContainerFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 08.08.2021.
//

import Foundation

class ModelsContainerFeature<Container: ModelsContainerProtocol>: BaseFeature<ModelsContainerFeature.UpdateModelsWish, Container, ModelsContainerFeature.ModelsUpdatedNews, ModelsContainerFeature.InnerPart> {
    struct UpdateModelsWish {
        let updated: [Container.Model]
        weak var updater: AnyObject?
    }
    
    struct ModelsUpdatedNews {
        let updated: [Container.ModelId: Container.Model]
        weak var updater: AnyObject?
    }
    
    init(initialState: Container) {
        super.init(initialState: initialState, innerPart: InnerPart())
    }
    
    struct InnerPart: InnerFeatureProtocol {
        typealias Wish = UpdateModelsWish
        typealias News = ModelsUpdatedNews
        typealias State = Container
        typealias Action = UpdateModelsWish
        typealias Effect = UpdateModelsWish
        
        fileprivate init() {}

        func reduce(with effect: Effect, state: inout State) {}
        
        func news(from action: Action, effect: Effect, state: State) -> News? {
            let dict = Dictionary(effect.updated.map { ($0.id, $0) }, uniquingKeysWith: { v, _ in v })
            return ModelsUpdatedNews(updated: dict, updater: effect.updater)
        }
    }
}

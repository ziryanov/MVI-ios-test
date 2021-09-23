//
//  ModelsContainerFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 08.08.2021.
//

import Foundation

struct ModelsUpdatedNews<Model: ModelWithId> {
    let updated: [Model.ModelId: Model]
    weak var updater: AnyObject?
}

class ModelsContainerFeature<Container: ModelsContainer>: BaseFeature<ModelsContainerFeature.UpdateModelsWish, Container, ModelsUpdatedNews<Container.Model>, ModelsContainerFeature.InnerPart> {
    struct UpdateModelsWish {
        let updated: [Container.Model]
        weak var updater: AnyObject?
    }
    
    init(initialState: Container) {
        super.init(initialState: initialState, innerPart: InnerPart())
    }
    
    struct InnerPart: FeatureInnerPart {
        typealias Wish = UpdateModelsWish
        typealias News = ModelsUpdatedNews<Container.Model>
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

//
//  PostsContainerFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 08.08.2021.
//

import Foundation
import DITranquillity

final class PostsContainerFeature: ModelsContainerFeature<PostsContainer> {
    
    final class DI: DIPart {
        static func load(container: DIContainer) {
            container.register { PostsContainerFeature.init(initialState: PostsContainer()) }
                .lifetime(.single)
            container.register(LikingPostFeature.init)
                .lifetime(.single)
        }
    }
}

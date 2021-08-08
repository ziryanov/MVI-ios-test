//
//  UsersContainerFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 08.08.2021.
//

import Foundation
import DITranquillity

final class UsersContainerFeature: ModelsContainerFeature<UsersContainer> {
    
    final class DI: DIPart {
        static func load(container: DIContainer) {
            container.register { UsersContainerFeature.init(initialState: UsersContainer()) }
                .lifetime(.single)
        }
    }
}

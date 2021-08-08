//
//  ModelsContainerDI.swift
//  MVI-ios-test
//
//  Created by ziryanov on 08.08.2021.
//

import Foundation
import DITranquillity

final class ModelsContainerDI: DIPart {
    
    public static func load(container: DIContainer) {
        container.append(part: PostsContainerFeature.DI.self)
        container.append(part: UsersContainerFeature.DI.self)
    }
}

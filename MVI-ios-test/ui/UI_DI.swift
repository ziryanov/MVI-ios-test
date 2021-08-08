//
//  UI_DI.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation
import DITranquillity

class UI_DI: DIPart {
    
    public static func load(container: DIContainer) {
        container.append(part: RootVCModule.DI.self)
//
        container.append(part: AuthVCModule.DI.self)
//        container.append(part: FeedVCModule.DI.self)
//        container.append(part: PostsVCModule.DI.self)
//        container.append(part: UserVCModule.DI.self)
//        container.append(part: ParchmentVCModule.DI.self)
//        container.append(part: UsersListVCModule.DI.self)
//
//        //temp
//        container.registerStoryboard(name: "Temp")
//            .lifetime(.single)
//        container.register(TempVC.self)
//            .lifetime(.objectGraph)
    }
}

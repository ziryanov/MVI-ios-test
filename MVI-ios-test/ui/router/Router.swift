//
//  Router.swift
//  MVI-ios-test
//
//  Created by ziryanov on 03.08.2021.
//

import UIKit

struct Router {
    enum Screen: Equatable {
        case root
        case auth
        case mainTabs
        case generalPosts
        case posts(source: Posts2StepSource)
        case user(UsersContainer.BasicUserInfo)
    }

    let screen: Screen
    init(screen: Screen) {
        self.screen = screen
    }
    
    func craeteViewController() -> UIViewController {
        switch screen {
        case .root:
            let feature: RouterFeature = container.resolve()
            return RootVCModule.Presenter.createAndReturnView(with: feature)
        case .auth:
            let feature: AuthFeature = container.resolve()
            return AuthVCModule.Presenter<AuthVC>.createAndReturnView(with: feature)
        case .mainTabs:
            return MainTabsVC.controllerFromStoryboard()
        case .generalPosts:
            let feature: PostsGeneralFeature = container.resolve()
            return PostsVCModule.PresenterGeneral.createAndReturnView(with: feature)
        case .posts(let source):
            container.extensions(for: Post2StepFeature.self)?.setArgs(source)
            let feature: Post2StepFeature = container.resolve()
            return PostsVCModule.Presenter2Step.createAndReturnView(with: feature)
        case .user(let userBasic):
            container.extensions(for: UserFeature.self)?.setArgs(userBasic)
            let feature: UserFeature = container.resolve()
            return UserVCModule.Presenter.createAndReturnView(with: feature)
        }
    }
}

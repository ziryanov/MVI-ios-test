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
    }

    let screen: Screen
    init(screen: Screen) {
        self.screen = screen
    }
    
    func craeteViewController() -> UIViewController {
        switch screen {
        case .root:
            let presenter: RootVCModule.Presenter = container.resolve()
            return presenter.view
        case .auth:
            let presenter: AuthVCModule.Presenter = container.resolve()
            return presenter.view
        case .mainTabs:
            return MainTabsVC.controllerFromStoryboard()
        case .generalPosts:
            let presenter: PostsVCModule.PresenterGeneral = container.resolve()
            return presenter.view
        case .posts(let source):
            container.extensions(for: Post2StepFeature.self)?.setArgs(source)
            let presenter: PostsVCModule.Presenter2Step = container.resolve()
            return presenter.view
        }
    }
}

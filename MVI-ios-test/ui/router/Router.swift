//
//  Router.swift
//  MVI-ios-test
//
//  Created by ziryanov on 03.08.2021.
//

import UIKit

struct Router {
    enum Screen {
        case root
        case auth
        case mainTabs
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
            fatalError()
        }
    }
}

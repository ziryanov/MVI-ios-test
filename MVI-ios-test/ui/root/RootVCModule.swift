//
//  RootVCModule.swift
//  MVI-ios-test
//
//  Created by ziryanov on 02.08.2021.
//

import Foundation
import DITranquillity

enum RootVCModule {

    typealias ViewController = RootVC
    
    enum Props {
        case loading
        case rootScreen(Router)
    }

    final class Presenter: PresenterBase<ViewController, SessionFeature> {
        override func createView() -> ViewController {
            return RootVC.controllerFromStoryboard()
        }
        
        override func props(for state: State) -> Props {
            switch state {
            case .waitingAuth:
                return .rootScreen(Router(screen: .auth))
            case .signedIn:
                return .rootScreen(Router(screen: .mainTabs))
            default:
                return .loading
            }
        }
        
        override func actions(for state: PresenterBase<RootVCModule.ViewController, SessionFeature>.State) -> () { () }
    }
    
    final class DI: DIPart {
        static func load(container: DIContainer) {
            container.register (SessionFeature.init)
                .lifetime(.single)
            container.register (Presenter.init)
                .lifetime(.single)
        }
    }
}

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
    typealias Props = Void

    final class Presenter: PresenterBase<ViewController, RouterFeature> {
        override func _props(for state: State) -> Props { () }
        override func _actions(for state: State) -> ViewController.Actions { () }
    }
    
    final class DI: DIPart {
        static func load(container: DIContainer) {
            container.register (SessionFeature.init)
                .lifetime(.single)
            container.register (RouterFeature.init)
                .lifetime(.single)
        }
    }
}

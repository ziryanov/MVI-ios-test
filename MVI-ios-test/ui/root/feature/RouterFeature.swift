//
//  RouterFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 11.08.2021.
//

import Foundation
import RxSwift

enum RouterWish {
    case showModal(Router.Screen)
    case push(Router.Screen)
}

final class RouterFeature: BaseFeature<RouterFeature.Wish, RouterFeature.State, RouterFeature.News, RouterFeature.InnerPart> {
    typealias Wish = RouterWish
    typealias State = Void
    enum News {
        case changeRoot(Router)
        case showModal(Router)
        case push(Router)
    }
    
    init(sessionFeature: SessionFeature) {
        super.init(initialState: (), innerPart: InnerPart(sessionFeature: sessionFeature))
    }

    struct InnerPart: FeatureInnerPart {
        private let sessionFeature: SessionFeature
        fileprivate init(sessionFeature: SessionFeature) {
            self.sessionFeature = sessionFeature
        }
        
        typealias Wish = RouterFeature.Wish
        typealias News = RouterFeature.News
        typealias State = RouterFeature.State
        enum Action {
            case changeRoot(Router.Screen)
            case showModal(Router.Screen)
            case push(Router.Screen)
        }
        typealias Effect = Action

        func bootstrapper() -> Observable<Action> {
            sessionFeature
                .flatMap { state -> Maybe<Action> in
                    switch state {
                    case .waitingAuth:
                        return .just(.changeRoot(.auth))
                    case .signedIn:
                        return .just(.changeRoot(.mainTabs))
                    default:
                        return .empty()
                    }
                }
        }
        
        func action(from wish: Wish) -> Action {
            switch wish {
            case .push(let screen):
                return .push(screen)
            case .showModal(let screen):
                return .showModal(screen)
            }
        }
        
        func news(from action: Action, effect: Effect, state: State) -> News? {
            switch action {
            case .changeRoot(let screen):
                return .changeRoot(Router(screen: screen))
            case .showModal(let screen):
                return .showModal(Router(screen: screen))
            case .push(let screen):
                return .push(Router(screen: screen))
            }
        }

        func reduce(with effect: Effect, state: inout State) {
        }
    }
}

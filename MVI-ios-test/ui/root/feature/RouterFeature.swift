//
//  RouterFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 11.08.2021.
//

import Foundation
import RxSwift

final class RouterFeature: BaseFeature<RouterFeature.Wish, RouterFeature.State, RouterFeature.News, RouterFeature.InnerPart> {
    enum Wish {
        case showModal(Router.Screen)
        case push(Router.Screen)
    }
    
    enum State {
        case inProgress
        case error(Error)
    }
    
    enum News {
        case changeRoot(Router)
        case showModal(Router)
        case push(Router)
    }
    
    init(sessionFeature: SessionFeature) {
        super.init(initialState: .inProgress, innerPart: InnerPart(sessionFeature: sessionFeature))
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

//
//  SessionFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 20.07.2021.
//

import Foundation
import Combine

final class SessionFeature: BaseFeature<SessionFeature.Wish, SessionFeature.Action, SessionFeature.Effect, SessionFeature.State, SessionFeature.News> {
    enum Wish {
        case logout
    }
    enum Action {
        case checkSession
        case logout
    }
    
    enum Effect {}
    struct State {
        var current = SessionState.checking
    }
    
    enum News {
        
    }
    
//    init() {
//        super.init(initialState: State(),
//                   bootstrapper: { Just(Action.checkSession).eraseToAnyPublisher() },
//                   wishToAction: { _ in.logout },
//                   actor: ActorImp(),
//                   reducer: <#T##Reducer<State, Effect>##Reducer<State, Effect>##(State, Effect) -> State#>, postProcessor: <#T##PostProcessor<Action, Effect, State>?##PostProcessor<Action, Effect, State>?##(Action, Effect, State) -> Action?#>, newsPublisher: <#T##NewsPublisher<Action, Effect, State, News>?##NewsPublisher<Action, Effect, State, News>?##(Action, Effect, State) -> News?#>)
//    }
//    
//    private class ActorImp: Actor<State, Action, Effect> {
//        
//    }
//    
//    private class ReducerImp: Reducer<State, Effect> {
//        
//    }
}

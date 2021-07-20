//
//  ReducerFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 18.07.2021.
//

import Foundation
import Combine

open class ReducerFeature<Wish, State, News>: BaseFeature<Wish, Wish, Wish, State, News> {
    
    public init(initialState: State,
                reducer: Reducer<State, Wish>,
                bootstrapper: Bootstrapper<Wish>? = nil,
                newsPublisher: SimpleNewsPublisher<Wish, State, News>? = nil) {
        super.init(initialState: initialState,
                   bootstrapper: bootstrapper,
                   wishToAction: BlockInvoker { $0 },
                   actor: SimpleActor(),
                   reducer: reducer,
                   newsPublisher: newsPublisher)
    }
    
    private class SimpleActor: Invoker<(State, Wish), AnyPublisher<Wish, Never>> {
        override func invoke(_ t: (State, Wish)) -> AnyPublisher<Wish, Never> {
            Just(t.1).eraseToAnyPublisher()
        }
    }
    public class SimpleNewsPublisher<Wish, State, News>: NewsPublisher<Wish, Wish, State, News> {
//        public override func invoke(_ t: (Wish, Wish, State)) -> News? {
//            super.invoke((t.0))
//        }
    }
}



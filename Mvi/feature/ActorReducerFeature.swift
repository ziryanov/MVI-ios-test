//
//  ActorReducerFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 18.07.2021.
//

import Foundation

open class ActorReducerFeature<Wish, Effect, State, News> : BaseFeature<Wish, Wish, Effect, State, News> {

    public init(initialState: State,
                bootstrapper: Bootstrapper<Wish>? = nil,
                actor: Actor<State, Wish, Effect>,
                reducer: Reducer<State, Effect>,
                newsPublisher: NewsPublisher<Wish, Effect, State, News>? = nil) {
        super.init(initialState: initialState,
                   bootstrapper: bootstrapper,
                   wishToAction: BlockInvoker { $0 },
                   actor: actor,
                   reducer: reducer,
                   newsPublisher: newsPublisher)
    }
}

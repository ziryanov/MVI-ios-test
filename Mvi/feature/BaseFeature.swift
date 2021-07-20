//
//  Feature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 17.07.2021.
//

import Foundation
import Combine

public typealias Actor<State, Action, Wish> = Invoker<(State, Action), AnyPublisher<Wish, Never>>
public typealias Bootstrapper<Action> = Invoker<Void, AnyPublisher<Action, Never>>
public typealias NewsPublisher<Action, Effect, State, News> = Invoker<(Action, Effect, State), News?>
public typealias PostProcessor<Action, Effect, State> = Invoker<(Action, Effect, State), Action?>
public typealias Reducer<State, Effect> = Invoker<(State, Effect), State>
public typealias WishToAction<Wish, Action> = Invoker<Wish, Action>

open class BaseFeature<Wish, Action, Effect, State, News>: Consumer<Wish>, Publisher {
    
    public typealias Output = State
    public typealias Failure = Never
    
    public var state: State {
        stateSubject.value
    }
    
    public var news: PassthroughSubject<News, Never> {
        newsSubject
    }
    
    private let stateSubject: CurrentValueSubject<State, Never>
    private let actionSubject = PassthroughSubject<Action, Never>()
    private let newsSubject = PassthroughSubject<News, Never>()
    private var disposables = DisposableCollection()
    private let actorWrapper: Consumer<(State, Action)>
    private let wishToAction: WishToAction<Wish, Action>
    
    init(initialState: State,
         bootstrapper: Bootstrapper<Action>? = nil,
         wishToAction: WishToAction<Wish, Action>,
         actor: Actor<State, Action, Effect>,
         reducer: Reducer<State, Effect>,
         postProcessor: PostProcessor<Action, Effect, State>? = nil,
         newsPublisher: NewsPublisher<Action, Effect, State, News>? = nil) {
        
        stateSubject = CurrentValueSubject(initialState)
        self.wishToAction = wishToAction
        
        let postProcessorWrapper = postProcessor.let { [actionSubject] in
            PostProcessorWrapper(postProcessor: $0, actions: actionSubject).wrapWithMiddleware(wrapperOf: $0)
        }
        let newsPublisherWrapper = newsPublisher.let { [newsSubject] in
            NewsPublisherWrapper(newsPublisher: $0, news: newsSubject).wrapWithMiddleware(wrapperOf: newsPublisher)
        }
        
        let reducerWrapper = ReducerWrapper(reducer: reducer, states: stateSubject, postProcessorWrapper: postProcessorWrapper, newsPublisherWrapper: newsPublisherWrapper).wrapWithMiddleware(wrapperOf: reducer)
        
        actorWrapper = ActorWrapper(disposables: disposables, actor: actor, stateSubject: stateSubject, reducerWrapper: reducerWrapper).wrapWithMiddleware(wrapperOf: actor)
        
        super.init()
        
        disposables += actionSubject.sink { [unowned self] in
            self.actorWrapper.accept((self.state, $0))
        }
        
        if let bootstrapper = bootstrapper {
            disposables += bootstrapper.invoke(())
                .sink { [weak self] in
                    self?.actionSubject.asConsumer().wrapWithMiddleware(wrapperOf: bootstrapper).accept($0)
                }
        }
    }
    
    private final class PostProcessorWrapper: Consumer<(Action, Effect, State)> {
        init(postProcessor: PostProcessor<Action, Effect, State>, actions: PassthroughSubject<Action, Never>) {
            self.postProcessor = postProcessor
            self.actions = actions
        }
        
        private let postProcessor: PostProcessor<Action, Effect, State>
        private let actions: PassthroughSubject<Action, Never>
        
        override func accept(_ t: (Action, Effect, State)) {
            guard let result = postProcessor.invoke(t) else { return }
            actions.send(result)
        }
    }
    
    private final class NewsPublisherWrapper: Consumer<(Action, Effect, State)> {
        init(newsPublisher: NewsPublisher<Action, Effect, State, News>, news: PassthroughSubject<News, Never>) {
            self.newsPublisher = newsPublisher
            self.news = news
        }
        
        private let newsPublisher: NewsPublisher<Action, Effect, State, News>
        private let news: PassthroughSubject<News, Never>
        
        override func accept(_ t: (Action, Effect, State)) {
            guard let result = newsPublisher.invoke(t) else { return }
            news.send(result)
        }
    }
    
    private final class ReducerWrapper: Consumer<(State, Action, Effect)> {
        init(reducer: Reducer<State, Effect>, states: CurrentValueSubject<State, Never>, postProcessorWrapper: Consumer<(Action, Effect, State)>?, newsPublisherWrapper: Consumer<(Action, Effect, State)>?) {
            self.reducer = reducer
            self.states = states
            self.postProcessorWrapper = postProcessorWrapper
            self.newsPublisherWrapper = newsPublisherWrapper
        }
        
        private let reducer: Reducer<State, Effect>
        private let states: CurrentValueSubject<State, Never>
        private let postProcessorWrapper: Consumer<(Action, Effect, State)>?
        private let newsPublisherWrapper: Consumer<(Action, Effect, State)>?
        
        override func accept(_ t: (State, Action, Effect)) {
            let (state, action, effect) = t
            let newState = reducer.invoke((state, effect))
            states.send(newState)
            postProcessorWrapper?.accept((action, effect, newState))
            newsPublisherWrapper?.accept((action, effect, newState))
        }
    }
    
    private final class ActorWrapper: Consumer<(State, Action)> {
        internal init(disposables: DisposableCollection, actor: Actor<State, Action, Effect>, stateSubject: CurrentValueSubject<State, Never>, reducerWrapper: Consumer<(State, Action, Effect)>) {
            self.disposables = disposables
            self.actor = actor
            self.stateSubject = stateSubject
            self.reducerWrapper = reducerWrapper
        }
        
        private let disposables: DisposableCollection
        private let actor: Actor<State, Action, Effect>
        private let stateSubject: CurrentValueSubject<State, Never>
        private let reducerWrapper: Consumer<(State, Action, Effect)>
        
        override func accept(_ t: (State, Action)) {
            disposables += actor.invoke(t)
                .sink { [unowned self] in
                    self.reducerWrapper.accept((self.stateSubject.value, t.1, $0))
                }
        }
    }


    override func accept(_ wish: Wish) {
        let action = wishToAction.invoke(wish)
        actionSubject.send(action)
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        stateSubject.receive(subscriber: subscriber)
    }
}

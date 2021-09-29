//
//  Feature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 17.07.2021.
//

import Foundation
import RxSwift
import RxRelay

public protocol StateHolder: AnyObject {
    associatedtype State
    var state: State { get }
}

public protocol NewsProvider {
    associatedtype News
    var news: Observable<News> { get }
}

public protocol Feature: Consumer, StateHolder, NewsProvider, ObservableType where State == Element { }

public protocol FeatureInnerPart {
    associatedtype Wish
    associatedtype Action
    associatedtype Effect
    associatedtype State
    associatedtype News
    
    func action(from wish: Wish) -> Action
    
    func bootstrapper() -> Observable<Action>
    
    func actor<Holder: StateHolder>(from action: Action, stateHolder: Holder) -> Observable<Effect> where Holder.State == State
    
    func reduce(with effect: Effect, state: inout State)
    
    func news(from action: Action, effect: Effect, state: State) -> News?
    
    func postProcessor(oldState: State, action: Action, effect: Effect, state: State) -> Action?
}

extension FeatureInnerPart where Self: Any {
    func bootstrapper() -> Observable<Action> {
        .empty()
    }
    
    func news(from action: Action, effect: Effect, state: State) -> News? {
        nil
    }
    
    func postProcessor(oldState: State, action: Action, effect: Effect, state: State) -> Action? {
        nil
    }
}

extension FeatureInnerPart where Wish == Action {
    func action(from wish: Wish) -> Action {
        wish
    }
}

extension FeatureInnerPart where Effect == Action {
    func actor<Holder: StateHolder>(from action: Action, stateHolder: Holder) -> Observable<Effect> where Holder.State == State {
        .just(action)
    }
}

extension FeatureInnerPart where State == Void {
    func reduce(with effect: State, state: inout State) { }
}

extension FeatureInnerPart where Wish == Void {
    func action(from wish: Void) -> Action {
        fatalError()
    }
}

open class BaseFeature<Wish, State, News, InnerPart: FeatureInnerPart>: Feature where InnerPart.Wish == Wish, InnerPart.State == State, InnerPart.News == News {
    public typealias Consumable = Wish
    public typealias Element = State
    
    public var state: State {
        stateSubject.value
    }

    public var news: Observable<News> {
        newsSubject.asObservable()
    }
    
    public func accept(_ wish: Wish) {
        startActor(with: innerPart.action(from: wish))
    }

    public func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer : ObserverType, Element == Observer.Element {
        stateSubject.subscribe(observer)
    }
    
    private let innerPart: InnerPart
    public init(initialState: State, innerPart: InnerPart) {
        self.innerPart = innerPart
        stateSubject = .init(value: initialState)

        innerPart.bootstrapper().delay(.milliseconds(0), scheduler: RxHolder.mainScheduler)
            .subscribe(onNext: { [weak self] in
                self?.startActor(with: $0)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func startActor(with action: InnerPart.Action) {
        innerPart.actor(from: action, stateHolder: self)
            .subscribe(onNext: { [weak self] effect in
                guard let self = self else { return }
                let oldState = self.state
                var copy = oldState
                self.innerPart.reduce(with: effect, state: &copy)
                self.stateSubject.accept(copy)
                if let news = self.innerPart.news(from: action, effect: effect, state: copy) {
                    self.newsSubject.accept(news)
                }
                if let ppAction = self.innerPart.postProcessor(oldState: oldState, action: action, effect: effect, state: copy) {
                    self.startActor(with: ppAction)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private let stateSubject: BehaviorRelay<State>
    private let newsSubject = PublishRelay<News>()
    private(set) var disposeBag = DisposeBag()
}

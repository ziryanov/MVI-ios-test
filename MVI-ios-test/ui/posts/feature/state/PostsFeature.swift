//
//  PostsFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 08.08.2021.
//

import Foundation

protocol PostsRequesterRefreshResultProtocol {
    var loaded: [PostsContainer.Model] { get }
}

protocol PostsRequester {
    associatedtype State
    associatedtype RefreshResult: PostsRequesterRefreshResultProtocol
    
    typealias LoadMoreResult = [PostsContainer.Model]
    
    func updateStateAfterSuccessRefresh(state: inout State, result: RefreshResult)
    func updateStateAfterSuccessLoadMore(state: inout State, result: LoadMoreResult)
    
    func refresh(state: State, perPage: Int) -> Single<RefreshResult>
    func loadMore(state: State, perPage: Int) -> Single<LoadMoreResult>
}

class PostsBaseFeature<PostState: PostsStateProtocol, Requester: PostsRequester>: BaseFeature<PostsBaseFeature.Wish, PostState, PostsBaseFeature.LoadingFinishedNews, PostsBaseFeature.InnerPart> where Requester.State == PostState {
    
    init(state: PostState, containerFeature: PostsContainerFeature, requester: Requester) {
        let innerPart = InnerPart(containerFeature: containerFeature, requester: requester)
        super.init(initialState: state, innerPart: innerPart)
        
        news
            .subscribe(onNext: {
                containerFeature.accept(.init(updated: $0.models, updater: innerPart))
            })
            .disposed(by: disposeBag)
    }
    
    enum Wish {
        case refresh, loadMore
    }
    
    struct LoadingFinishedNews {
        let models: [PostsContainer.Model]
    }
    
    class InnerPart: InnerFeatureProtocol {
        private let requester: Requester
        private let containerFeature: PostsContainerFeature
        private weak var skipUpdatedFrom: AnyObject?
        fileprivate init(containerFeature: PostsContainerFeature, requester: Requester) {
            self.containerFeature = containerFeature
            self.requester = requester
        }
        
        enum Action {
            case wish(Wish)
            case updateModels([PostsContainer.Model])
        }
        typealias State = PostState
        enum Effect {
            case startRefresh
            case finishRefresh(Requester.RefreshResult)
            case refreshFailed(String)
            
            case startLoadMore
            case finishLoadMore([PostsContainer.Model])
            case loadMoreFailed(String)
            
            case updateLoaded([PostsContainer.Model])
        }
        typealias News = LoadingFinishedNews
        
        func bootstrapper() -> Observable<Action> {
            containerFeature.news
                .skipWhile { [weak self] in $0.updater === self }
                .map { Action.updateModels($0.updated) }
        }
        
        func action(from wish: Wish) -> Action {
            .wish(wish)
        }

        func actor<Holder>(from action: Action, stateHolder: Holder) -> Observable<Effect> where Holder : StateHolder, State == Holder.State {
            let currentState = stateHolder.state
            switch action {
            case .wish(let wish):
                switch wish {
                case .refresh:
                    let initialStateChange = Maybe<Effect>.create { [weak stateHolder] observer in
                        if stateHolder?.state.currentState == .initialLoading {
                            observer(.completed)
                        } else {
                            observer(.success(.startRefresh))
                        }
                        return Disposables.create()
                    }
                    
                    let request = requester
                        .refresh(state: currentState, perPage: perPage)
                        .map { Effect.finishRefresh($0) }
                        .asObservable()
                        .catchError { _ in .just(Effect.refreshFailed("refresh failed")) }
                    
                    return initialStateChange.asObservable()
                        .concat(request)
                    
                case .loadMore:
                    let loadMore = requester
                        .loadMore(state: currentState, perPage: perPage)
                        .map { Effect.finishLoadMore($0) }
                        .catchError { _ in .just(Effect.loadMoreFailed("load more failed")) }
                    
                    return Observable
                        .just(Effect.startLoadMore)
                        .concat(loadMore)
                }
            case .updateModels(let models):
                return Maybe<Effect>
                    .create { observer in
                        let needUpdateIds = Set(models.map { $0.id }).intersection(stateHolder.state.loaded.map { $0.id })
                        if needUpdateIds.isEmpty {
                            observer(.completed)
                        } else {
                            let needUpdateFromArray = models.filter { needUpdateIds.contains($0.id) }
                            let updateFrom = Dictionary(needUpdateFromArray.map { ($0.id, $0) }, uniquingKeysWith: { f, _ in f })
                            var loaded = stateHolder.state.loaded
                            for i in 0..<loaded.count {
                                let id = loaded[i].id
                                guard let updateTo = updateFrom[id] else { continue }
                                loaded[i] = updateTo
                            }
                            observer(.success(.updateLoaded(loaded)))
                        }
                        return Disposables.create()
                    }
                    .asObservable()
            }
        }

        func reduce(with effect: Effect, state: inout State) {
            switch effect {
            case .startRefresh:
                state.currentState = .refreshing
            case .finishRefresh(let result):
                state.currentState = .loaded(error: nil)
                state.loaded = result.loaded
                requester.updateStateAfterSuccessRefresh(state: &state, result: result)
            case .refreshFailed(let text):
                state.currentState = .loaded(error: text)
            case .startLoadMore:
                state.currentState = .loadingMore
            case .finishLoadMore(let models):
                state.currentState = .loaded(error: nil)
                state.loaded += models
                requester.updateStateAfterSuccessLoadMore(state: &state, result: models)
            case .loadMoreFailed(let text):
                state.currentState = .loaded(error: text)
            case .updateLoaded(let models):
                state.loaded = models
            }
        }
        
        func news(from action: Wish, effect: Effect, state: State) -> News? {
            switch effect {
            case .finishRefresh(let result):
                return LoadingFinishedNews(models: result.loaded)
            case .finishLoadMore(let models):
                return LoadingFinishedNews(models: models)
            default:
                return nil
            }
        }
        
        private let perPage = 20
    }
}

//
//  PostsFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 08.08.2021.
//

import Foundation

enum TableViewWish {
    case refresh, loadMore
}

struct PostsLoadingFinishedNews {
    let loadedModels: [PostsContainer.Model]
}

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

class PostsBaseFeature<PostState: PostsStateProtocol, Requester: PostsRequester>: BaseFeature<TableViewWish, PostState, PostsLoadingFinishedNews, PostsBaseFeature.InnerPart> where Requester.State == PostState {
    
    init(state: PostState, containerFeature: PostsContainerFeature?, requester: Requester) {
        let innerPart = InnerPart(postsUpdates: containerFeature?.news ?? .empty(), requester: requester)
        super.init(initialState: state, innerPart: innerPart)
        
        if containerFeature != nil {
            news
                .subscribe(onNext: { [weak containerFeature] in
                    containerFeature?.accept(.init(updated: $0.loadedModels, updater: innerPart))
                })
                .disposed(by: disposeBag)
        }
    }
    
    class InnerPart: InnerFeatureProtocol {
        private let requester: Requester
        private let postsUpdates: Observable<PostsContainerFeature.News>
        private weak var skipUpdatedFrom: AnyObject?
        fileprivate init(postsUpdates: Observable<PostsContainerFeature.News>, requester: Requester) {
            self.postsUpdates = postsUpdates
            self.requester = requester
        }
        
        typealias Wish = TableViewWish
        enum Action {
            case refresh
            case startRefreshRequest

            case loadMore
            case startLoadMoreRequest(UUID)

            case updateModels([PostsContainer.ModelId: PostsContainer.Model])
        }
        typealias State = PostState
        enum Effect {
            case startRefresh
            case finishRefresh(Requester.RefreshResult)
            case refreshFailed(String)
            
            case startLoadMore(UUID)
            case finishLoadMore([PostsContainer.Model])
            
            case updateLoaded([PostsContainer.Model])
        }
        typealias News = PostsLoadingFinishedNews
        
        func bootstrapper() -> Observable<Action> {
            let array: [Observable<Action>] = [
                Observable.just(Action.startRefreshRequest),
                postsUpdates
                    .skipWhile { [weak self] in $0.updater === self }
                    .map { Action.updateModels($0.updated) }
            ]
            return Observable.merge(array)
        }
        
        func action(from wish: Wish) -> Action {
            switch wish {
            case .refresh:
                return .refresh
            case .loadMore:
                return .loadMore
            }
        }

        func actor<Holder>(from action: Action, stateHolder: Holder) -> Observable<Effect> where Holder : StateHolder, State == Holder.State {
            switch action {
            case .refresh:
                return Maybe<Effect>
                    .just(.startRefresh, if: stateHolder.state.currentState != .initialLoading && stateHolder.state.currentState != .refreshing)
                    .asObservable()
            case .startRefreshRequest:
                return requester
                    .refresh(state: stateHolder.state, perPage: perPage)
                    .map { Effect.finishRefresh($0) }
                    .catchError { _ in .just(Effect.refreshFailed("refresh failed")) }
                    .asObservable()
            case .loadMore:
                return Maybe<Effect>
                    .just(.startLoadMore(UUID()), if: stateHolder.state.currentState == .loaded)
                    .asObservable()
            case .startLoadMoreRequest(let uuid):
                return requester
                    .loadMore(state: stateHolder.state, perPage: perPage)
                    .map { [weak stateHolder] in
                        guard case .loadingMore(let currentUuid) = stateHolder?.state.currentState, currentUuid == uuid else {
                            throw ApiError(reason: .cancelled)
                        }
                        return Effect.finishLoadMore($0)
                    }
                    .catchError { _ in .just(Effect.finishLoadMore([])) }
                    .asObservable()
            case .updateModels(let modelsDict):
                return Maybe<Effect>
                    .createSimple {
                        let needUpdateIds = Set(modelsDict.keys).intersection(stateHolder.state.loaded.map { $0.id })
                        guard !needUpdateIds.isEmpty else { return nil }
                        var loaded = stateHolder.state.loaded
                        for i in 0..<loaded.count {
                            let id = loaded[i].id
                            guard let updateTo = modelsDict[id] else { continue }
                            loaded[i] = updateTo
                        }
                        return .updateLoaded(loaded)
                    }
                    .asObservable()
            }
        }

        func reduce(with effect: Effect, state: inout State) {
            switch effect {
            case .startRefresh:
                state.currentState = .refreshing
            case .finishRefresh(let result):
                state.currentState = .loaded
                state.loaded = result.loaded
                requester.updateStateAfterSuccessRefresh(state: &state, result: result)
            case .refreshFailed(let text):
                state.currentState = .failed(text)
            case .startLoadMore(let uuid):
                state.currentState = .loadingMore(uuid)
            case .finishLoadMore(let models):
                state.currentState = .loaded
                state.loaded += models
                requester.updateStateAfterSuccessLoadMore(state: &state, result: models)
            case .updateLoaded(let models):
                state.loaded = models
            }
        }
        
        func news(from action: Wish, effect: Effect, state: State) -> News? {
            switch effect {
            case .finishRefresh(let result):
                return PostsLoadingFinishedNews(loadedModels: result.loaded)
            case .finishLoadMore(let models):
                return PostsLoadingFinishedNews(loadedModels: models)
            default:
                return nil
            }
        }
        
        func postProcessor(oldState: PostState, action: Action, effect: Effect, state: PostState) -> Action? {
            if oldState.currentState != state.currentState {
                switch state.currentState {
                case .initialLoading, .refreshing:
                    return .startRefreshRequest
                case .loadingMore(let uuid):
                    return .startLoadMoreRequest(uuid)
                default:
                    break
                }
            }
            return nil
        }
        
        private let perPage = 20
    }
}

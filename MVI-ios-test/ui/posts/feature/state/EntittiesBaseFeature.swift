//
//  EntittiesBaseFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 08.08.2021.
//

import Foundation

enum TableViewWish<LoadingMoreOptions> {
    case refresh
    case loadMore(LoadingMoreOptions)
}

struct EntitiesLoadingFinishedNews<Model: ModelWithId> {
    let loadedModels: [Model]
}

protocol EntitiesRequester_Result {
    associatedtype Model
    var loaded: [Model] { get }
}

protocol EntitiesRequester {
    associatedtype State: EntitiesState
    associatedtype RefreshResult: EntitiesRequester_Result where RefreshResult.Model == State.Model
    
    typealias LoadingMoreOptions = State.LoadingMoreOptions
    associatedtype LoadMoreResult: EntitiesRequester_Result where LoadMoreResult.Model == State.Model
    
    func updateStateAfterSuccessRefresh(state: inout State, result: RefreshResult)
    func updateStateAfterSuccessLoadMore(state: inout State, option: LoadingMoreOptions, result: LoadMoreResult)
    
    func refresh(state: State, perPage: Int) -> Single<RefreshResult>
    func loadMore(_ option: LoadingMoreOptions, state: State, perPage: Int) -> Single<LoadMoreResult>
    
    var perPage: Int { get }
}

class EntitiesBaseFeature<State, Requester: EntitiesRequester>: BaseFeature<TableViewWish<State.LoadingMoreOptions>, State, EntitiesLoadingFinishedNews<State.Model>, EntitiesBaseFeature.InnerPart> where Requester.State == State {
    typealias Model = State.Model
    typealias LoadingMoreOptions = State.LoadingMoreOptions
    
    init<Contanier: ModelsContainer>(state: State, containerFeature: ModelsContainerFeature<Contanier>?, requester: Requester) where Contanier.Model == Model {
        let innerPart = InnerPart(updates: containerFeature?.news ?? .empty(), requester: requester)
        super.init(initialState: state, innerPart: innerPart)
        
        if containerFeature != nil {
            news
                .subscribe(onNext: { [weak containerFeature] in
                    containerFeature?.accept(.init(updated: $0.loadedModels, updater: innerPart))
                })
                .disposed(by: disposeBag)
        }
    }
    
    class InnerPart: FeatureInnerPart {
        private let requester: Requester
        private let updates: Observable<ModelsUpdatedNews<Model>>
        private weak var skipUpdatedFrom: AnyObject?
        fileprivate init(updates: Observable<ModelsUpdatedNews<Model>>, requester: Requester) {
            self.updates = updates
            self.requester = requester
        }
        
        typealias Wish = TableViewWish<LoadingMoreOptions>
        enum Action {
            case refresh
            case startRefreshRequest

            case loadMore(LoadingMoreOptions)
            case startLoadMoreRequest(LoadingMoreOptions, UUID)

            case updateModels([Model.ModelId: Model])
        }

        enum Effect {
            case startRefresh
            case finishRefresh(Requester.RefreshResult)
            case refreshFailed(String)
            
            case startLoadMore(LoadingMoreOptions, UUID)
            case finishLoadMore(LoadingMoreOptions, Requester.LoadMoreResult?)
            
            case updateLoaded([Model])
        }
        typealias News = EntitiesLoadingFinishedNews<Model>
        
        func bootstrapper() -> Observable<Action> {
            let array: [Observable<Action>] = [
                Observable.just(Action.startRefreshRequest),
                updates
                    .skipWhile { [weak self] in $0.updater === self }
                    .map { Action.updateModels($0.updated) }
            ]
            return Observable.merge(array)
        }
        
        func action(from wish: Wish) -> Action {
            switch wish {
            case .refresh:
                return .refresh
            case .loadMore(let option):
                return .loadMore(option)
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
                    .refresh(state: stateHolder.state, perPage: requester.perPage)
                    .map { Effect.finishRefresh($0) }
                    .catchError { _ in .just(Effect.refreshFailed("refresh failed")) }
                    .asObservable()
            case .loadMore(let option):
                return Maybe<Effect>
                    .just(.startLoadMore(option, UUID()), if: stateHolder.state.currentState.isReadyForLoadMore(for: option) && stateHolder.state.loadMoreEnabled(for: option))
                    .asObservable()
            case .startLoadMoreRequest(let option, let uuid):
                return requester
                    .loadMore(option, state: stateHolder.state, perPage: requester.perPage)
                    .map { [weak stateHolder] in
                        guard stateHolder?.state.currentState.isLoadingMore(for: option, and: uuid) == true else {
                            throw ApiError.cancelled
                        }
                        return Effect.finishLoadMore(option, $0)
                    }
                    .catchError { _ in .just(Effect.finishLoadMore(option, nil)) }
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
            case .startLoadMore(let option, let uuid):
                state.currentState.setLoadMore(for: option, uuid: uuid)
            case .finishLoadMore(let option, let result):
                state.currentState.setLoadMore(for: option, uuid: nil)
                if let result = result {
                    state.loaded += result.loaded
                    requester.updateStateAfterSuccessLoadMore(state: &state, option: option, result: result)
                }
            case .updateLoaded(let models):
                state.loaded = models
            }
        }
        
        func news(from action: Wish, effect: Effect, state: State) -> News? {
            switch effect {
            case .finishRefresh(let result):
                return EntitiesLoadingFinishedNews(loadedModels: result.loaded)
            case .finishLoadMore(_, let result):
                if let result = result {
                    return EntitiesLoadingFinishedNews(loadedModels: result.loaded)
                }
            default:
                break
            }
            return nil
        }
        
        func postProcessor(oldState: State, action: Action, effect: Effect, state: State) -> Action? {
            switch effect {
            case .startRefresh:
                return .startRefreshRequest
            case .startLoadMore(let option, let uuid):
                return .startLoadMoreRequest(option, uuid)
            default:
                break
            }
            return nil
        }
    }
}

typealias TableViewWishDefault = TableViewWish<LoadingMoreDefault>

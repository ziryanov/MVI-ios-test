//
//  UserFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 17.09.2021.
//

import Foundation
import RxSwift

final class UserFeature: BaseFeature<UserFeature.Wish, UserState, UserFeature.News, UserFeature.InnerPart> {
    
    enum Wish {
        case changeSegment(UserState.Segment)
        case refresh
        case loadMore
    }

    enum News {
        case loadedUser(UsersContainer.Model, [PostsContainer.Model])
        case loadedPosts([PostsContainer.Model])
    }

    init(base: UsersContainer.BasicUserInfo, network: Network, postsContainerFeature: PostsContainerFeature?, usersContainerFeature: UsersContainerFeature?) {
        let innerPart = InnerPart(network: network, postsUpdates: postsContainerFeature?.news ?? .empty(), usersUpdates: usersContainerFeature?.news ?? .empty())
        super.init(initialState: UserState(userBase: base), innerPart: innerPart)
        
        if postsContainerFeature != nil || usersContainerFeature != nil {
            news
                .subscribe(onNext: { [weak postsContainerFeature, weak usersContainerFeature] in
                    switch $0 {
                    case .loadedUser(let user, let posts):
                        usersContainerFeature?.accept(.init(updated: [user], updater: innerPart))
                        postsContainerFeature?.accept(.init(updated: posts, updater: innerPart))
                    case .loadedPosts(let posts):
                        postsContainerFeature?.accept(.init(updated: posts, updater: innerPart))
                    }
                })
                .disposed(by: disposeBag)
        }
    }

    class InnerPart: InnerFeatureProtocol {
        private let network: Network
        private let postsUpdates: Observable<PostsContainerFeature.News>
        private let usersUpdates: Observable<UsersContainerFeature.News>
        fileprivate init(network: Network, postsUpdates: Observable<PostsContainerFeature.News>, usersUpdates: Observable<UsersContainerFeature.News>) {
            self.network = network
            self.postsUpdates = postsUpdates
            self.usersUpdates = usersUpdates
        }

        typealias Wish = UserFeature.Wish
        typealias News = UserFeature.News
        typealias State = UserState

        enum Action {
            case changeSegment(UserState.Segment)
            case refresh
            case startRefreshRequest

            case loadMore
            case startLoadMoreRequest(UserState.Segment, UUID)

            case updateUserModel([UsersContainer.ModelId: UsersContainer.Model])
            case updatePostModels([PostsContainer.ModelId: PostsContainer.Model])
        }

        typealias UserPosts = [UserState.Segment: [PostsContainer.Model]]
        enum Effect {
            case changeSegment(UserState.Segment)
            
            case startRefresh
            case finishRefresh(UsersContainer.Model, UserPosts)
            case refreshFailed(String)
            
            case startLoadMorePosts(UserState.Segment, UUID)
            case finishLoadMorePosts(UserState.Segment, [PostsContainer.Model])
            case loadMorePostsFailed(UserState.Segment)
            
            case updateUserModelExceptPosts(UsersContainer.Model)
            case updatePostModels(UserPosts)
        }
        
        func bootstrapper() -> Observable<Action> {
            let array: [Observable<Action>] = [
                Observable.just(Action.startRefreshRequest),
                postsUpdates
                    .skipWhile { [weak self] in $0.updater === self }
                    .map { Action.updatePostModels($0.updated) },
                usersUpdates
                    .skipWhile { [weak self] in $0.updater === self }
                    .map { Action.updateUserModel($0.updated) }
            ]
            return Observable.merge(array)
        }
        
        func action(from wish: UserFeature.Wish) -> Action {
            switch wish {
            case .changeSegment(let segment):
                return .changeSegment(segment)
            case .refresh:
                return .refresh
            case .loadMore:
                return .loadMore
            }
        }
        
        func actor<Holder>(from action: Action, stateHolder: Holder) -> Observable<Effect> where Holder : StateHolder, State == Holder.State {
            switch action {
            case .changeSegment(let segment):
                return Maybe<Effect>
                    .just(.changeSegment(segment), if: stateHolder.state.currentSegment != segment)
                    .asObservable()
            case .refresh:
                return Maybe<Effect>
                    .just(.startRefresh, if: stateHolder.state.currentState != .initialLoading && stateHolder.state.currentState != .refreshing)
                    .asObservable()
            case .startRefreshRequest:
                let userId = stateHolder.state.userBase.id
                let perPage = self.perPage
                
                return loadUser(id: userId)
                    .asObservable()
                    .flatMap { [weak self] user -> Observable<Effect> in
                        guard let self = self else { return .error(ApiError(reason: .cancelled)) }
                        let loadPostsRequests: [Observable<(UserState.Segment, [PostsContainer.Model])>] = UserState.Segment.allCases
                            .map { segment in
                                let ids = user.postIds(for: segment)
                                let needLoadIds = Array(ids.prefix(perPage))
                                return self.loadPosts(ids: needLoadIds)
                                    .map { (segment, $0) }
                                    .asObservable()
                            }
                        return Observable.zip(loadPostsRequests)
                            .map { .finishRefresh(user, Dictionary($0, uniquingKeysWith: { _, v in v })) }
                    }
                    .catchError { _ in .just(Effect.refreshFailed("load user failed")) }
            case .loadMore:
                let segment = stateHolder.state.currentSegment
                return Maybe<Effect>
                    .just(.startLoadMorePosts(segment, UUID()), if: stateHolder.state.currentState.isReadyForLoadMore(for: segment))
                    .asObservable()
            case .startLoadMoreRequest(let segment, let uuid):
                guard let ids = stateHolder.state.loadedUser?.postIds(for: segment) else {
                    return .error(ApiError(reason: .internalLogicError))
                }
                let indexFrom = stateHolder.state.loadedPosts(for: segment).count
                let needLoadIds = Array(ids.suffix(from: indexFrom).prefix(perPage))
                
                return loadPosts(ids: needLoadIds)
                    .map { [weak stateHolder] in
                        guard stateHolder?.state.currentState.isLoadingMore(for: segment, and: uuid) == true else {
                            throw ApiError(reason: .cancelled)
                        }
                        return Effect.finishLoadMorePosts(segment, $0)
                    }
                    .catchError { _ in .just(Effect.loadMorePostsFailed(segment)) }
                    .asObservable()
            case .updateUserModel(let usersDict):
                return Maybe<Effect>
                    .createSimple {
                        guard let id = stateHolder.state.loadedUser?.id, let user = usersDict[id] else { return nil }
                        return .updateUserModelExceptPosts(user)
                    }
                    .asObservable()
            case .updatePostModels(let postsDict):
                return Maybe<Effect>
                    .createSimple {
                        let updatedPostsIds = Set(postsDict.keys)
                        
                        let loadedIdsTuples = UserState.Segment.allCases.map { segment in
                            (segment, stateHolder.state.loadedPosts(for: segment).map { $0.id })
                        }
                        let allLoadedIds = loadedIdsTuples.reduce(Set(), { $0.union($1.1) })
                        
                        let needUpdateIds = updatedPostsIds.intersection(allLoadedIds)
                        guard !needUpdateIds.isEmpty else { return nil }
                        
                        var updatedPosts = UserPosts()
                        for (segment, ids) in loadedIdsTuples {
                            guard !Set(ids).intersection(needUpdateIds).isEmpty else { continue }
                            var loaded = stateHolder.state.loadedPosts(for: segment)
                            for i in 0..<loaded.count {
                                let id = loaded[i].id
                                guard let updateTo = postsDict[id] else { continue }
                                loaded[i] = updateTo
                            }
                            updatedPosts[segment] = loaded
                        }
                        return .updatePostModels(updatedPosts)
                    }
                    .asObservable()
            }
        }
        
        func reduce(with effect: Effect, state: inout UserState) {
            switch effect {
            case .changeSegment(let segment):
                state.currentSegment = segment
            case .startRefresh:
                state.currentState = .refreshing
            case .finishRefresh(let user, let userPosts):
                state.loadedUser = user
                for (segment, posts) in userPosts {
                    state.updatePosts(for: segment) { $0 = posts }
                }
                state.currentState = .loaded
            case .refreshFailed(let text):
                state.currentState = .failed(text)
            case .startLoadMorePosts(let segment, let uuid):
                state.currentState.setLoadMore(for: segment, uuid: uuid)
            case .finishLoadMorePosts(let segment, let posts):
                state.updatePosts(for: segment, update: { $0.append(contentsOf: posts) })
                state.currentState.setLoadMore(for: segment, uuid: nil)
            case .loadMorePostsFailed(let segment):
                state.currentState.setLoadMore(for: segment, uuid: nil)
            case .updateUserModelExceptPosts(let user):
                guard let loadedUser = state.loadedUser else { return }
                let oldPostsIdsTuples = UserState.Segment.allCases.map { ($0, loadedUser.postIds(for: $0)) }
                state.loadedUser = user
                for (segment, ids) in oldPostsIdsTuples {
                    state.loadedUser?.setPostIds(ids, for: segment)
                }
            case .updatePostModels(let userPosts):
                for (segment, posts) in userPosts {
                    state.updatePosts(for: segment) { $0 = posts }
                }
            }
        }
        
        func postProcessor(oldState: UserState, action: Action, effect: Effect, state: UserState) -> Action? {
            switch effect {
            case .startRefresh:
                return .startRefreshRequest
            case .startLoadMorePosts(let segment, let uuid):
                return .startLoadMoreRequest(segment, uuid)
            default:
                return nil
            }
        }
        
        func news(from action: Action, effect: Effect, state: UserState) -> UserFeature.News? {
            switch effect {
            case .finishRefresh(let user, let userPosts):
                let alPosts = userPosts.reduce(Set(), { $0.union($1.value) })
                return News.loadedUser(user, Array(alPosts))
            case .finishLoadMorePosts(_, let posts):
                return News.loadedPosts(posts)
            default:
                return nil
            }
        }
        
        private func loadUser(id: UsersContainer.ModelId) -> Single<UsersContainer.Model> {
            network
                .request(.loadUser(userId: id))
                .map(UserDTO.self)
                .map {
                    guard let model = UsersContainer.Model(userId: id, dto: $0) else {
                        throw ApiError(reason: .mappingFailed, serverError: NetworkHelper.findServerError(errorSearchDict: $0))
                    }
                    return model
                }
        }
        
        private func loadPosts(ids: [PostsContainer.ModelId]) -> Single<[PostsContainer.Model]> {
            network
                .request(.getPosts(ids: ids))
                .map([PostDTO].self)
                .map {
                    $0.compactMap(PostsContainer.Post.init)
                }
        }
        
        private let perPage = 20
    }
}

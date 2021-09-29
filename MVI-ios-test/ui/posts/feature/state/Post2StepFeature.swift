//
//  Posts2Step.swift
//  MVI-ios-test
//
//  Created by ziryanov on 08.08.2021.
//

import Foundation
import RxSwift

typealias PostsLoadingFinishedNews = EntitiesLoadingFinishedNews<PostsContainer.Post>

final class Post2StepFeature: EntitiesBaseFeature<Posts2StepState, Post2StepFeature.Requester> {
    
    init(source: Posts2StepSource, containerFeature: PostsContainerFeature, network: Network) {
        super.init(state: .init(source: source), containerFeature: containerFeature, requester: Requester(network: network))
    }
    
    class Requester: EntitiesRequester {
        private let network: Network
        fileprivate init(network: Network) {
            self.network = network
        }
        typealias State = Posts2StepState
        struct RefreshResult: EntitiesRequester_Result {
            let allIds: [PostsContainer.ModelId]
            let requestedIds: [PostsContainer.ModelId]
            let loaded: [PostsContainer.Model]
        }
        struct LoadMoreResult: EntitiesRequester_Result {
            let requestedIds: [PostsContainer.ModelId]
            let loaded: [PostsContainer.Model]
        }
        
        func updateStateAfterSuccessRefresh(state: inout State, result: RefreshResult) {
            state.allIds = result.allIds
            state.requestedIds = result.requestedIds
        }
        
        func updateStateAfterSuccessLoadMore(state: inout State, option: LoadingMoreOptions, result: LoadMoreResult) {
            state.requestedIds.append(contentsOf: result.requestedIds)
        }
        
        private func requestIds(state: State) -> Single<[PostsContainer.ModelId]> {
            let token: API
            switch state.source {
            case .feed:
                token = .getFeedIds
            case .interesting:
                token = .getInterestingIds
            case .firstTwo:
                token = .getFirstTwo
            }
            
            return network
                .request(token)
                .mapJSON()
                .map {
                    guard let ids = $0 as? [PostsContainer.ModelId] else {
                        throw ApiError(reason: .mappingFailed, serverError: NetworkHelper.findServerError(errorSearchDict: $0))
                    }
                    return ids
                }
        }
        
        private func requestModels(ids: [PostsContainer.ModelId]) -> Single<[PostsContainer.Post]> {
            return network
                .request(.getPosts(ids: ids))
                .map(to: [PostDTO].self)
                .map { $0.compactMap(PostsContainer.Post.init) }
        }
        
        func refresh(state: State, perPage: Int) -> Single<RefreshResult> {
            self.requestIds(state: state)
                .flatMap { [weak self] ids -> Single<RefreshResult> in
                    guard let self = self else { return .error(ApiError.cancelled) }
                    let needLoadIds = Array(ids.prefix(perPage))
                    return self
                        .requestModels(ids: needLoadIds)
                        .map { RefreshResult(allIds: ids, requestedIds: needLoadIds, loaded: $0) }
                }
        }
        
        func loadMore(_ option: LoadingMoreOptions, state: State, perPage: Int) -> Single<LoadMoreResult> {
            guard let allIds = state.allIds else { return .error(ApiError(reason: .internalLogicError)) }
            let indexFrom = state.requestedIds.count
            let needLoadIds = Array(allIds.suffix(from: indexFrom).prefix(perPage))
            return requestModels(ids: needLoadIds)
                .map { LoadMoreResult(requestedIds: needLoadIds, loaded: $0) }
        }
        
        var perPage: Int = 20
    }
}

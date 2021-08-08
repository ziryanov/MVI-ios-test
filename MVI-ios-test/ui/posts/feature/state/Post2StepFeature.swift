//
//  Posts2Step.swift
//  MVI-ios-test
//
//  Created by ziryanov on 08.08.2021.
//

import Foundation

final class Post2StepFeature: PostsBaseFeature<Posts2StepState, Post2StepFeature.Requester> {
    
    init(source: Posts2StepSource, containerFeature: PostsContainerFeature, network: Network, requester: Requester) {
        super.init(state: .init(source: source), containerFeature: containerFeature, requester: Requester(network: network))
    }
    
    class Requester: PostsRequester {
        private let network: Network
        fileprivate init(network: Network) {
            self.network = network
        }
        typealias State = Posts2StepState
        struct RefreshResult: PostsRequesterRefreshResultProtocol {
            let allIds: [PostsContainer.ModelId]
            let loaded: [PostsContainer.Model]
        }
        
        func updateStateAfterSuccessRefresh(state: inout State, result: RefreshResult) {
            state.allIds = result.allIds
        }
        
        func updateStateAfterSuccessLoadMore(state: inout State, result: LoadMoreResult) { }
        
        private func requestIds(state: State) -> Single<[PostsContainer.ModelId]> {
            let token: API
            switch state.source {
            case .general:
                token = .getFeedIds
            case .interesting:
                token = .getInterestingIds
            case .notInteresting:
                token = .getFirstTwo
            }
            
            return network
                .request(token)
                .mapJSON()
                .map {
                    guard let ids = $0 as? [PostsContainer.ModelId] else { throw ApiError.mappingFailed }
                    return ids
                }
        }
        
        private func requestModels(ids: [PostsContainer.ModelId]) -> Single<[PostsContainer.Model]> {
            return network
                .request(.getPosts(ids: ids))
                .map(to: [PostDTO].self)
                .map {
                    $0.compactMap(PostsContainer.Post.init)
                }
        }
        
        func refresh(state: State, perPage: Int) -> Single<RefreshResult> {
            self.requestIds(state: state)
                .flatMap { [weak self] ids -> Single<RefreshResult> in
                    guard let self = self else { return .error(ApiError.mappingFailed) }
                    let needLoadIds = Array(ids.prefix(perPage))
                    return self
                        .requestModels(ids: needLoadIds)
                        .map { RefreshResult(allIds: ids, loaded: $0) }
                }
        }
        
        func loadMore(state: State, perPage: Int) -> Single<[PostsContainer.Model]> {
            guard let allIds = state.allIds else { return .error(ApiError.mappingFailed) }
            let indexFrom = state.loaded.count
            let needLoadIds = Array(allIds.suffix(from: indexFrom).prefix(perPage))
            return self.requestModels(ids: needLoadIds)
        }
    }
}

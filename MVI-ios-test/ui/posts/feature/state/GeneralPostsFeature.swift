//
//  GeneralPostsFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 08.08.2021.
//

import Foundation

final class PostsGeneralFeature: PostsBaseFeature<GeneralPostsState, PostsGeneralFeature.Requester> {
    
    init(containerFeature: PostsContainerFeature, network: Network) {
        super.init(state: .init(), containerFeature: containerFeature, requester: Requester(network: network))
    }
    
    class Requester: PostsRequester {
        private let network: Network
        fileprivate init(network: Network) {
            self.network = network
        }
        typealias State = GeneralPostsState
        struct RefreshResult: PostsRequesterRefreshResultProtocol {
            let loaded: [PostsContainer.Model]
        }
        
        func updateStateAfterSuccessRefresh(state: inout State, result: RefreshResult) { }
        
        func updateStateAfterSuccessLoadMore(state: inout State, result: LoadMoreResult) {
            state.hasMoreModels = !result.isEmpty
        }
        
        private func request(state: State, perPage: Int) -> Single<[PostsContainer.Model]> {
            let after = state.currentState == .loadingMore ? state.loaded.last?.id : 0
            
            return network
                .request(.getImportantPosts(perPage: perPage, after: after))
                .map(to: [PostDTO].self)
                .map {
                    $0.compactMap(PostsContainer.Post.init)
                }
        }
        
        func refresh(state: State, perPage: Int) -> Single<RefreshResult> {
            request(state: state, perPage: perPage)
                .map { RefreshResult(loaded: $0) }
        }
        
        func loadMore(state: State, perPage: Int) -> Single<[PostsContainer.Model]> {
            request(state: state, perPage: perPage)
        }
    }
}

//
//  Poststate.swift
//  ReduxVMSample
//
//  Created by ziryanov on 16.10.2020.
//

import Foundation

enum Posts2StepSource: Equatable {
    case feed
    case interesting
    case firstTwo
}

struct Posts2StepState: EntitiesState {
    typealias Model = PostsContainer.Post
    
    let source: Posts2StepSource
    
    var currentState = TableListStateDefault.initialLoading
    
    var allIds: [PostsContainer.ModelId]? = nil
    var requestedIds = [PostsContainer.ModelId]()
    var loaded = [PostsContainer.Model]()
    
    func loadMoreEnabled(for: LoadingMoreDefault) -> Bool {
        return requestedIds.last != allIds?.last
    }
}

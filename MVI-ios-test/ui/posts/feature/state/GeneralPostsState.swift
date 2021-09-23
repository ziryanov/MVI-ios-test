//
//  GeneralPostsState.swift
//  ReduxVMSample
//
//  Created by ziryanov on 11.11.2020.
//

import Foundation

struct GeneralPostsState: EntitiesState {
    typealias Model = PostsContainer.Post
    
    var currentState = TableListStateDefault.initialLoading
    var loaded = [PostsContainer.Model]()
    
    var hasNoMoreModels = false
    func loadMoreEnabled(for: LoadingMoreDefault) -> Bool {
        !hasNoMoreModels
    }
}

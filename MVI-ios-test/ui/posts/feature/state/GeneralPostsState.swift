//
//  GeneralPostsState.swift
//  ReduxVMSample
//
//  Created by ziryanov on 11.11.2020.
//

import Foundation

struct GeneralPostsState: PostsStateProtocol {
    var uuid = UUID().uuidString
    
    var currentState = TableListState.initialLoading
    var loaded = [PostsContainer.Model]()
    
    var hasMoreModels = false
    var loadMoreEnabled: Bool {
        guard currentState == .loaded(error: nil) else { return false }
        return hasMoreModels
    }
}

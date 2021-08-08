//
//  Poststate.swift
//  ReduxVMSample
//
//  Created by ziryanov on 16.10.2020.
//

import Foundation

enum Posts2StepSource {
    case general
    case interesting
    case notInteresting
}

struct Posts2StepState: PostsStateProtocol {
    var uuid = UUID().uuidString
    let source: Posts2StepSource
    
    var currentState = TableListState.initialLoading
    
    var allIds: [PostsContainer.ModelId]? = nil
    var loaded = [PostsContainer.Model]()
    
    var loadMoreEnabled: Bool {
        guard let allIds = allIds, currentState == .loaded(error: nil), !loaded.isEmpty else { return false }
        return loaded.count < allIds.count
    }
}

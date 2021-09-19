//
//  PostsStateProtocol.swift
//  ReduxVMSample
//
//  Created by ziryanov on 11.11.2020.
//

import Foundation

protocol PostsStateProtocol {
    var currentState: TableListState { get set }
    var loaded: [PostsContainer.Model] { get set }
    var loadMoreEnabled: Bool { get }
}

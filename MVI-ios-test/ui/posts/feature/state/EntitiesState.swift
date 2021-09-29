//
//  EntitiesState.swift
//  ReduxVMSample
//
//  Created by ziryanov on 11.11.2020.
//

import Foundation

enum TableListState<LoadingMoreOptions: Hashable>: Equatable {
    case initialLoading
    case loaded
    case failed(String)
    case refreshing
    
    case loadingMore([LoadingMoreOptions: UUID])
}

protocol EntitiesState {
    associatedtype Model: ModelWithId
    associatedtype LoadingMoreOptions: Hashable
    
    var currentState: TableListState<LoadingMoreOptions> { get set }
    var loaded: [Model] { get set }
    func loadMoreEnabled(for: LoadingMoreOptions) -> Bool
}

enum LoadingMoreDefault {
    case more
}

typealias TableListStateDefault = TableListState<LoadingMoreDefault>

enum LoadingMoreTwoWays {
    case after
    case before
}

extension TableListState {
    func isReadyForLoadMore(for option: LoadingMoreOptions) -> Bool {
        switch self {
        case .loaded:
            return true
        case .loadingMore(let dict):
            return dict[option] == nil
        default:
            return false
        }
    }
    
    func isLoadingMore(for option: LoadingMoreOptions, and uuid: UUID) -> Bool {
        switch self {
        case .loadingMore(let dict):
            return dict[option] == uuid
        default:
            return false
        }
    }
    
    mutating func setLoadMore(for option: LoadingMoreOptions, uuid: UUID?) {
        var loadMoreInfo: [LoadingMoreOptions: UUID]
        if case .loadingMore(let dict) = self {
            loadMoreInfo = dict
        } else {
            loadMoreInfo = .init()
        }
        loadMoreInfo[option] = uuid
        if loadMoreInfo.isEmpty {
            self = .loaded
        } else {
            self = .loadingMore(loadMoreInfo)
        }
    }
}

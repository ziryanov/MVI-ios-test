//
//  State+ui.swift
//  MVI-ios-test
//
//  Created by ziryanov on 08.08.2021.
//

import Foundation
import CoreGraphics

enum TableListState: Equatable {
    case initialLoading
    case loaded(error: String?)
    case refreshing
    case loadingMore
}

//extension TableListState {
//    var initialLoading: Bool {
//        if case .initialLoading = self {
//            return true
//        }
//        return false
//    }
//    
//    var refreshing: Bool {
//        if case .refreshing = self {
//            return true
//        }
//        return false
//    }
//    
//    var isLoaded: Bool {
//        if case .loaded = self {
//            return true
//        }
//        return false
//    }
//}

protocol HasTableListState {
    var currentState: TableListState { get set }
}


struct ImageWithRatio: Hashable {
    let image: String
    let ratio: CGFloat
}


enum SingleModelState {
    case loading
    case loaded(error: String?)
}

extension SingleModelState {
    var isLoaded: Bool {
        if case .loaded = self {
            return true
        }
        return false
    }
}

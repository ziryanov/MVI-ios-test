//
//  State+ui.swift
//  MVI-ios-test
//
//  Created by ziryanov on 08.08.2021.
//

import Foundation
import CoreGraphics

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

//========================

struct ImageWithRatio: Hashable, Equatable {
    let image: String
    let ratio: CGFloat
}

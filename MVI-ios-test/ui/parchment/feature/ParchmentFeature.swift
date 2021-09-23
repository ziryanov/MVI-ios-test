//
//  ParchmentFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 16.08.2021.
//

import Foundation

final class ParchmentFeature: BaseFeature<ParchmentFeature.Wish, ParchmentState, Never, ParchmentFeature.InnerPart> {
    enum Wish {
        case changeChildIndex(Int)
        case changeSubsegmentInCurrentChild(Int)
    }
    
    struct InnerPart: FeatureInnerPart {
        typealias Wish = ParchmentFeature.Wish
        typealias News = Never
        typealias State = ParchmentState
        typealias Action = Wish
        typealias Effect = Wish
        
        func reduce(with effect: Effect, state: inout State) {
            switch effect {
            case .changeChildIndex(let new):
                state.activeChildIndex = new
            case .changeSubsegmentInCurrentChild(let new):
                state.segments[state.activeChildIndex].selectedIndex = new
            }
        }
    }
}

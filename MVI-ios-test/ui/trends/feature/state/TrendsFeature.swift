//
//  TrendsFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 25.09.2021.
//

import Foundation
import RxSwift

final class TrendsFeature: BaseFeature<Void, TrendsFeature.State, Void, TrendsFeature.InnerPart> {
    
    struct State {
        struct Trend {
            let id: String
            let name: String
            let position: Int
            let previousPosition: (Int, changedOnUpdateId: Int)?
            
            static fileprivate func unknown(position: Int) -> Trend {
                Trend(id: UUID().uuidString, name: "unknown", position: 0, previousPosition: nil)
            }
            static let previousPositionsStayedTicks = 4
        }
        var trends = [Trend]()
        
        var lastUpdatedId = -1
    }
    
    init(network: NetworkType) {
        super.init(initialState: State(), innerPart: InnerPart(network: network))
    }

    class InnerPart: FeatureInnerPart {
        private let network: NetworkType
        fileprivate init(network: NetworkType) {
            self.network = network
        }

        typealias Wish = Void
        typealias News = Void
        typealias State = TrendsFeature.State
        enum Action {
            case update(id: Int)
        }
        enum Effect {
            case update([State.Trend], updateId: Int)
        }
        
        func bootstrapper() -> Observable<Action> {
            Observable<Int>
                .timer(.seconds(0), period: .seconds(1), scheduler: RxHolder.mainScheduler) //if change period be care about int overflow
                .map { .update(id: $0) }
        }
                
        func actor<Holder>(from action: Action, stateHolder: Holder) -> Observable<Effect> where Holder : StateHolder, State == Holder.State {
            switch action {
            case let .update(updateId):
                return getTrends()
                    .flatMapMaybe { [weak stateHolder] trends -> Maybe<Effect> in
                        guard let state = stateHolder?.state, state.lastUpdatedId < updateId else {
                            return .empty()
                        }
                        let updated = trends.enumerated().map { (index, dto) -> State.Trend in
                            guard let id = dto.id,
                                  let name = dto.name else {
                                return .unknown(position: index)
                            }
                            var previousPosition: (Int, changedOnUpdateId: Int)? = nil
                            if let previous = state.trends.first(where: { $0.id == id }) {
                                if let prevPreviousPosition = previous.previousPosition, updateId - prevPreviousPosition.changedOnUpdateId <= State.Trend.previousPositionsStayedTicks {
                                    previousPosition = prevPreviousPosition
                                } else {
                                    previousPosition = (previous.position, updateId)
                                }
                            }
                            return .init(id: id, name: name, position: index, previousPosition: previousPosition)
                        }
                        
                        return .just(.update(updated, updateId: updateId))
                    }
                    .asObservable()
            }
        }

        func reduce(with effect: Effect, state: inout State) {
            switch effect {
            case let .update(trends, updatedId):
                state.trends = trends
                state.lastUpdatedId = updatedId
            }
        }
        
        private func getTrends() -> Single<[TrendDTO]> {
            network
                .request(.getTrends)
                .map([TrendDTO].self)
        }
    }
}

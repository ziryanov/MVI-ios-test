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
        typealias UpdateTime = Int
        struct Trend: Equatable, Hashable {
            let id: String
            let name: String
            let position: Int
            struct PreviousPosition: Equatable, Hashable {
                let position: Int
                let updateTime: UpdateTime
            }
            let previous: PreviousPosition?
            
            static fileprivate func unknown(position: Int) -> Trend {
                Trend(id: UUID().uuidString, name: "unknown", position: position, previous: nil)
            }
            static let previousPositionsStayedTime: UpdateTime = 4
        }
        var trends = [Trend]()
        
        var lastUpdateTime: UpdateTime = -1
        var currentUpdateTime: UpdateTime = -1
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
            case update(time: State.UpdateTime)
        }
        enum Effect {
            case updateCurrentTime(State.UpdateTime)
            case update([State.Trend], updateTime: State.UpdateTime)
        }
        
        func bootstrapper() -> Observable<Action> {
            let period = DispatchTimeInterval.seconds(1) //if change period be care about int overflow in timer
            let koeff = 1
            return Observable<Int>
                .timer(.seconds(0), period: period, scheduler: RxHolder.mainScheduler)
                .map { .update(time: koeff * $0) }
        }
                
        func actor<Holder>(from action: Action, stateHolder: Holder) -> Observable<Effect> where Holder : StateHolder, State == Holder.State {
            switch action {
            case let .update(updateTime):
                let updateCurrentTime = Observable<Effect>.just(.updateCurrentTime(updateTime))
                let request = getTrends()
                    .flatMapMaybe { [weak stateHolder] trends -> Maybe<Effect> in
                        guard let state = stateHolder?.state, state.lastUpdateTime < updateTime else {
                            return .empty()
                        }
                        let updated = trends.enumerated().map { (index, dto) -> State.Trend in
                            let newPosition = index + 1
                            guard let id = dto.id,
                                  let name = dto.name else {
                                return .unknown(position: newPosition)
                            }
                            let previous: State.Trend.PreviousPosition?
                            if let old = state.trends.first(where: { $0.id == id }) {
                                if newPosition == old.position, let previousPrevious = old.previous, previousPrevious.position != newPosition, previousPrevious.updateTime >= updateTime - State.Trend.previousPositionsStayedTime {
                                    previous = previousPrevious
                                } else {
                                    previous = .init(position: old.position, updateTime: updateTime)
                                }
                            } else {
                                previous = nil
                            }
                            return .init(id: id, name: name, position: newPosition, previous: previous)
                        }
                        return .just(.update(updated, updateTime: updateTime))
                    }
                    .asObservable()
                return Observable<Effect>.concat([updateCurrentTime, request])
            }
        }

        func reduce(with effect: Effect, state: inout State) {
            switch effect {
            case let .update(trends, updateTime):
                state.trends = trends
                state.lastUpdateTime = updateTime
            case let .updateCurrentTime(currentTime):
                state.currentUpdateTime = currentTime
            }
        }
        
        private func getTrends() -> Single<[TrendDTO]> {
            network
                .request(.getTrends)
                .map([TrendDTO].self)
        }
    }
}

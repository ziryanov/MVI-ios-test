//
//  TrendsVCModule.swift
//  MVI-ios-test
//
//  Created by ziryanov on 05.10.2021.
//

import Foundation
import DeclarativeTVC
import DITranquillity

enum TrendsVCModule {
    typealias ViewController = TrendsVC
    
    public struct Props {
        let tableModel: TableModel
        let connectionIssues: Bool
    }
    typealias Actions = Void
    
    class Presenter: PresenterBase<ViewController, TrendsFeature> {
        
        override func _props(for state: State) -> ViewController.Props {
            var rows = [CellAnyModel]()
            
            rows.append(contentsOf: state.trends.map {
                TrendsCellVM(trend: $0)
            })
            
            return .init(tableModel: TableModel(rows: rows),
                         connectionIssues: state.currentUpdateTime > state.lastUpdateTime + State.Trend.previousPositionsStayedTime)
        }
        
        override func _actions(for state: State) -> ViewController.Actions { () }
    }
    
    final class DI: DIPart {
        static func load(container: DIContainer) {
            container.register(TrendsFeature.init)
                .lifetime(.objectGraph)
        }
    }
}

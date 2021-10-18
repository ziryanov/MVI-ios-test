//
//  DTVC.swift
//  MVI-ios-test
//
//  Created by ziryanov on 05.10.2021.
//

import UIKit
import DeclarativeTVC

open class DefaultTVC<News>: TVC<DefaultTVC.Props, DefaultTVC.Actions, News> {
    public struct Props {
        let tableModel: TableModel
        let refreshing: Bool
    }

    public struct Actions {
        let refresh: Command
        let loadMore: Command
    }
    
    public override func render(props: Props) {
        set(model: props.tableModel, animations: nil)
        
        if props.refreshing != refreshControl?.isRefreshing {
            if props.refreshing {
                refreshControl?.beginRefreshing()
            } else {
                refreshControl?.endRefreshing()
            }
        }
    }
    
    public override func apply(actions: Actions) {
        tableView.rx.willDisplayCell
            .bind { [action = actions.loadMore, unowned tableView] (_, ip) in
                if tableView!.distanceToEnd(from: ip) < 5 {
                    action.perform()
                }
            }
            .disposed(by: rx.disposeBag(tag: "More"))
        
        refreshControl?.rx.controlEvent(.valueChanged)
            .bind { [action = actions.refresh] _ in
                action.perform()
            }
            .disposed(by: rx.disposeBag(tag: "Refresh"))
    }
}

extension UITableView {
    func distanceToEnd(from: IndexPath) -> Int {
        var result = numberOfRows(inSection: from.section) - from.row
        for section in from.section + 1 ..< numberOfSections {
            result += numberOfRows(inSection: section)
        }
        return result
    }
}

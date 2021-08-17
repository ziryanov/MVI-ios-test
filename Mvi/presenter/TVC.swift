//
//  TVC.swift
//  MVI-ios-test
//
//  Created by ziryanov on 11.08.2021.
//

import Foundation
import DeclarativeTVC

public class TVC: DeclarativeTVC, PropsReceiver, ActionsReceiver, HasPresenter, PropsReceiverWithSubscriptionBehaviour {
    public struct Props {
        let tableModel: TableModel
        let refreshing: Bool
    }

    public struct Actions {
        let refresh: Command
        let loadMore: Command
    }
    
    var presenter: PresenterProtocol!
    static var subscriptionBehaviour: PropsReceiverSubscriptionBehaviour {
        return .onAppearing
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if type(of: self).subscriptionBehaviour == .always {
            presenter.subscribe()
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if type(of: self).subscriptionBehaviour == .onAppearing {
//        if ReduxVMSettings.logSubscribeMessages {
//            print("subscribe presenter \(type(of: self))")
//        }
            presenter.subscribe()
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if type(of: self).subscriptionBehaviour == .onAppearing {
//        if ReduxVMSettings.logSubscribeMessages {
//            print("unsubscribe presenter \(type(of: self))")
//        }
            presenter.unsubscribe()
        }
    }
    
    public func render(props: Props) {
        set(model: props.tableModel, animations: nil)
        
        if props.refreshing != refreshControl?.isRefreshing {
            if props.refreshing {
                refreshControl?.beginRefreshing()
            } else {
                refreshControl?.endRefreshing()
            }
        }
    }
    
    public func apply(actions: Actions) {
        tableView.rx.willDisplayCell
            .bind { [action = actions.loadMore, unowned tableView] (_, ip) in
                if tableView!.distanceToEnd(from: ip) < 10 {
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

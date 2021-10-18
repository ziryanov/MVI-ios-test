//
//  VC.swift
//  MVI-ios-test
//
//  Created by ziryanov on 05.10.2021.
//

import UIKit

open class VC<Props, Actions, News>: UIViewController, PropsReceiver, ActionsReceiver, NewsConsumer, PresenterHolder, PropsReceiverWithSubscriptionBehaviour {
    public var _presenter: Presenter!
    
    open var subscriptionBehaviour: PropsReceiverSubscriptionBehaviour {
        return .onAppearing
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if subscriptionBehaviour == .always {
            _presenter.subscribe()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if subscriptionBehaviour == .onAppearing {
            _presenter.subscribe()
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if subscriptionBehaviour == .onAppearing {
            _presenter.unsubscribe()
        }
    }
    
    //to override
    open func render(props: Props) { }
    open func apply(actions: Actions) { }
    open func accept(news: News) { }
}

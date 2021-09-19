//
//  PropsReceiver.swift
//  MVI-ios-test
//
//  Created by ziryanov on 01.08.2021.
//

import UIKit

public protocol PropsReceiver {
    associatedtype Props

    func render(props: Props)
}

public protocol ActionsReceiver {
    associatedtype Actions

    func apply(actions: Actions)
}

public protocol PresenterHolder {
    var _presenter: PresenterProtocol! { get set }
}

public enum PropsReceiverSubscriptionBehaviour {
    case always
    case onAppearing
}

public protocol PropsReceiverWithSubscriptionBehaviour {
    var subscriptionBehaviour: PropsReceiverSubscriptionBehaviour { get }
}

open class VC<Props, Actions, Consumable>: UIViewController, PropsReceiver, ActionsReceiver, Consumer, PresenterHolder, PropsReceiverWithSubscriptionBehaviour {
    public var _presenter: PresenterProtocol!
    
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
    open func accept(_ t: Consumable) { }
}

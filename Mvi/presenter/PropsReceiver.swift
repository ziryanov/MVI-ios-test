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

protocol HasPresenter: AnyObject {
    var presenter: PresenterProtocol! { get set }
}

enum PropsReceiverSubscriptionBehaviour {
    case always
    case onAppearing
}

protocol PropsReceiverWithSubscriptionBehaviour {
    static var subscriptionBehaviour: PropsReceiverSubscriptionBehaviour { get }
}

open class VC<Props, Actions>: UIViewController, PropsReceiver, ActionsReceiver, HasPresenter, PropsReceiverWithSubscriptionBehaviour {
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
    
    //to override
    public func render(props: Props) { }
    public func apply(actions: Actions) { }
}

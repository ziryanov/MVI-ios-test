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

open class VC<Props, Actions>: UIViewController, PropsReceiver, ActionsReceiver, HasPresenter {
    var presenter: PresenterProtocol!
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        if ReduxVMSettings.logSubscribeMessages {
//            print("subscribe presenter \(type(of: self))")
//        }
        presenter.subscribe()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

//        if ReduxVMSettings.logSubscribeMessages {
//            print("unsubscribe presenter \(type(of: self))")
//        }
        presenter.unsubscribe()
    }
    
    //to override
    public func render(props: Props) {
        
    }
    
    public func apply(actions: Actions) {
        
    }
}

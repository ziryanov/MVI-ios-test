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
    var _presenter: Presenter! { get set }
}

public enum PropsReceiverSubscriptionBehaviour {
    case always
    case onAppearing
}

public protocol PropsReceiverWithSubscriptionBehaviour {
    var subscriptionBehaviour: PropsReceiverSubscriptionBehaviour { get }
}

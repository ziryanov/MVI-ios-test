//
//  PresenterBase.swift
//  MVI-ios-test
//
//  Created by ziryanov on 01.08.2021.
//

import Foundation
import RxSwift

public protocol Presenter {
    func subscribe()
    func unsubscribe()
}

open class PresenterBase<View: PropsReceiver & ActionsReceiver & Consumer & PresenterHolder & AnyObject, PresenterFeature: Feature>: Presenter where View.Consumable == PresenterFeature.News {

    public typealias State = PresenterFeature.Element

    public let feature: PresenterFeature
    
    public static func createAndReturnView(with feature: PresenterFeature) -> View {
        let presenter = self.init(feature: feature)
        return presenter.createVC()
    }

    private let disposeBag = DisposeBag()
    required public init(feature: PresenterFeature) {
        self.feature = feature
    }
    
    internal weak var view: View!
    
    private func createVC() -> View {
        var view = _createView()
        view._presenter = self
        self.view = view

        feature.news
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.view?.accept($0)
            })
            .disposed(by: disposeBag)
        
        return view
    }

    private var subscribeDB = DisposeBag()
    public func subscribe() {
        unsubscribe()

        render(feature.state)

        feature
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                self.render($0)
            })
            .disposed(by: subscribeDB)
    }

    public func unsubscribe() {
        subscribeDB = DisposeBag()
    }

    private var actionsApplied = false
    private func render(_ state: State) {
        view.render(props: _props(for: state))
        if !actionsApplied {
            view.apply(actions: _actions(for: state))
            actionsApplied = true
        }
    }

    //to override
    open func _props(for state: State) -> View.Props {
        fatalError("need implement")
    }

    open func _actions(for state: State) -> View.Actions {
        fatalError("need implement")
    }

    open func _createView() -> View {
        fatalError("need implement")
    }
}

import UIKit
extension PresenterBase where View: UIViewController {
    public var viewController: UIViewController? {
        return view
    }
}

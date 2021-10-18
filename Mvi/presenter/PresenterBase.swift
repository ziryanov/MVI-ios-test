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

public protocol NewsConsumer {
    associatedtype News
    func accept(news: News)
}

open class PresenterBase<View: PropsReceiver & ActionsReceiver & NewsConsumer & PresenterHolder & AnyObject, PresenterFeature: Feature>: Presenter where View.News == PresenterFeature.News {

    public typealias State = PresenterFeature.Element

    public let feature: PresenterFeature
    private var disposeBag = DisposeBag()
    required public init(feature: PresenterFeature, view: View) {
        self.feature = feature
        self.view = view
        self.view._presenter = self
        
        feature.news
            .observeOn(RxHolder.mainScheduler)
            .subscribe(onNext: { [weak self] in
                self?.view?.accept(news: $0)
            })
            .disposed(by: disposeBag)
    }
    
    internal weak var view: View!
    
    private var subscribeDB = DisposeBag()
    public func subscribe() {
        unsubscribe()

        render(feature.state)

        feature
            .observeOn(RxHolder.mainScheduler)
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
}

extension PresenterBase where View: UIViewController {
    static func createAndReturnView(with feature: PresenterFeature) -> UIViewController {
        let vc = View.controllerFromStoryboard()
        let presenter = self.init(feature: feature, view: vc)
        return presenter.view
    }
}

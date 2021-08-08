//
//  PresenterBase.swift
//  MVI-ios-test
//
//  Created by ziryanov on 01.08.2021.
//

import Foundation
import RxSwift

public protocol PresenterProtocol {
    func subscribe()
    func unsubscribe()
}

open class PresenterBase<View: PropsReceiver & ActionsReceiver & Consumer & AnyObject, PresenterFeature: FeatureProtocol>: PresenterProtocol where View.Consumable == PresenterFeature.News {

    public typealias State = PresenterFeature.Element

    weak var view: View!
    let feature: PresenterFeature

    init(feature: PresenterFeature) {
        self.feature = feature
        self.view = createView()
        if let view = self.view as? HasPresenter {
            view.presenter = self
        }
    }

    private var disposeBag = DisposeBag()
    public func subscribe() {
        unsubscribe()

        render(feature.state)

        feature
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                self.render($0)
            })

            .disposed(by: disposeBag)

        feature.news
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak view] in
                view?.accept($0)
            })
            .disposed(by: disposeBag)
    }

    public func unsubscribe() {
        disposeBag = DisposeBag()
    }

    private var actionsApplied = false
    private func render(_ state: State) {
        view.render(props: props(for: state))
        if !actionsApplied {
            view.apply(actions: actions(for: state))
            actionsApplied = true
        }
    }

    //to override
    open func props(for state: State) -> View.Props {
        fatalError("need implement")
    }

    open func actions(for state: State) -> View.Actions {
        fatalError("need implement")
    }

    open func createView() -> View {
        fatalError("need implement")
    }
}

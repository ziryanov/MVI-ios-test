//
//  AFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 18.09.2021.
//

import Foundation

class AFeature: BaseFeature<Int, Int, Int, AFeature.InnerPart> {
    
    init() {
        super.init(initialState: 1, innerPart: InnerPart())
    }
    class InnerPart: InnerFeatureProtocol {
        func reduce(with effect: Wish, state: inout Int) {
            state = effect
        }
        
        typealias Wish = Int
        typealias Action = Wish
        typealias Effect = Wish
        typealias State = Int
        typealias News = Int
        
        
    }
}

import UIKit

enum AVCModule {
    typealias ViewController = AVC
    typealias Props = Int

    final class Presenter: PresenterBase<ViewController, AFeature> {
        override func _createView() -> ViewController {
            return ViewController.controllerFromStoryboard()
        }
        
        override func _props(for state: State) -> ViewController.Props { state }
        override func _actions(for state: State) -> ViewController.Actions { state }
    }
}


final class AVC: VC<AVCModule.Props, Int, Int> {
    override class var storyboardName: String { "Easy" }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .yellow
        
        let button = UIButton(frame: CGRect(x: 20, y: 100, width: 100, height: 100))
        button.backgroundColor = .green
        view.addSubview(button)
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    @IBAction private func buttonPressed() {
        UIApplication.shared.keyWindow?.rootViewController = BVCModule.Presenter.createAndReturnView(with: AFeature())
    }
    
    deinit {
        print("deinit A")
    }
}


enum BVCModule {
    typealias ViewController = BVC
    typealias Props = Int

    final class Presenter: PresenterBase<ViewController, AFeature> {
        override func _createView() -> ViewController {
            return ViewController()
        }
        
        override func _props(for state: State) -> ViewController.Props { state }
        override func _actions(for state: State) -> ViewController.Actions { state }
    }
}


final class BVC: VC<BVCModule.Props, Int, Int> {
    override class var storyboardName: String { "Easy" }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .red
        let button = UIButton(frame: CGRect(x: 20, y: 100, width: 100, height: 100))
        button.backgroundColor = .green
        view.addSubview(button)
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    @IBAction private func buttonPressed() {
        UIApplication.shared.keyWindow?.rootViewController = AVCModule.Presenter.createAndReturnView(with: AFeature())
    }
    
    deinit {
        print("deinit B")
    }
}

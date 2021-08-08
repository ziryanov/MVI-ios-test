//
//  RootVC.swift
//  MVI-ios-test
//
//  Created by ziryanov on 17.07.2021.
//

import UIKit
import NVActivityIndicatorView

final class RootVC: VC<RootVCModule.Props, Void>, Consumer {
    typealias Consumable = SessionFeature.News
    
    public class override var storyboardName: String {
        return "Root"
    }
    
    @IBOutlet private var activityView: NVActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityView.startAnimating()
    }
    
    private var currentScreen: Router.Screen?
    override func render(props: RootVCModule.Props) {
        switch props {
        case .loading:
            break
        case .rootScreen(let router):
            activityView.stopAnimating()
            guard router.screen != currentScreen else { return }
            let vc = router.craeteViewController()
            if let child = children.first {
                addChild(vc)
                child.willMove(toParent: nil)
                transition(from: child, to: vc, duration: 0.2, options: [.transitionFlipFromLeft], animations: nil) { _ in
                    child.removeFromParent()
                    vc.didMove(toParent: self)
                }
            } else {
                add(vc)
            }
            currentScreen = router.screen
        }
    }

    func accept(_ t: SessionFeature.News) {}
}


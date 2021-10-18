//
//  RootVC.swift
//  MVI-ios-test
//
//  Created by ziryanov on 17.07.2021.
//

import UIKit
import NVActivityIndicatorView

final class RootVC: VC<RootVCModule.Props, Void, RouterFeature.News> {
    public class override var storyboardName: String {
        return "Root"
    }
    
    @IBOutlet private var activityView: NVActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityView.startAnimating()
    }
    
    override func render(props: RootVCModule.Props) { }

    private var rootScreen: Router.Screen?
    override func accept(news: RouterFeature.News) {
        switch news {
        case .changeRoot(let router):
            activityView.stopAnimating()
            guard rootScreen != router.screen else { fatalError("no!") }
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
            rootScreen = router.screen
        case .showModal(let router):
            let vc = router.craeteViewController()
            topNVC()?.viewControllers.last?.present(vc, animated: true)
        case .push(let router):
            let vc = router.craeteViewController()
            topNVC()?.pushViewController(vc, animated: true)
        }
    }
    
    private func topNVC() -> UINavigationController? {
        if var modal = presentedViewController {
            while let next = modal.presentedViewController {
                modal = next
            }
            return modal.navigationController
        } else if let child = children.first as? UINavigationController {
            return child
        } else if let child = children.first as? UITabBarController {
            return child.selectedViewController as? UINavigationController
        }
        return nil
    }
}


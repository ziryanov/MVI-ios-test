//
//  UIViewController+child.swift
//  MVI-ios-test
//
//  Created by ziryanov on 04.08.2021.
//

import UIKit

extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        child.view.frame = view.bounds
        child.view.translatesAutoresizingMaskIntoConstraints = true
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    func wrapInNVC() -> UINavigationController {
        UINavigationController(rootViewController: self)
    }
}

//
//  LogoutVC.swift
//  MVI-ios-test
//
//  Created by ziryanov on 11.08.2021.
//

import UIKit

final class LogoutVC: UIViewController {

    override class var storyboardName: String {
        return "MainTabs"
    }
    
    @IBAction private func logoutPressed() {
        let feature: SessionFeature = container.resolve()
        feature.accept(wish: .logout)
    }
}

//
//  MainTabsVC.swift
//  MVI-ios-test
//
//  Created by ziryanov on 11.08.2021.
//

import UIKit
import SwiftIconFont

final class MainTabsVC: UITabBarController {
    
    override class var storyboardName: String {
        return "MainTabs"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let router1 = Router(screen: .posts(source: .feed))
        let vc1 = router1.craeteViewController()

        let router2 = Router(screen: .generalPosts)
        let vc2 = router2.craeteViewController()
        
        let routerTrends = Router(screen: .trends)
        let vcTrends = routerTrends.craeteViewController()
        
        let vcLogout = LogoutVC.controllerFromStoryboard()
        
        viewControllers = [vc1.wrapInNVC(), vc2.wrapInNVC(), vcTrends.wrapInNVC(), vcLogout.wrapInNVC()]
        
        let iconSize = CGSize(width: 25, height: 25)
        let icons = [ UIImage(named: "tab.feed"),
                      UIImage(from: .fontAwesome5Solid, code: "rss-square", size: iconSize),
                      UIImage(from: .fontAwesome5Solid, code: "poll", size: iconSize),
                      UIImage(named: "tab.settings") ]
        tabBar.items?.enumerated().forEach {
            $0.1.image = icons[$0.0]
        }
    }
}

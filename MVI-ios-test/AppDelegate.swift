//
//  AppDelegate.swift
//  MVI-ios-test
//
//  Created by ziryanov on 17.07.2021.
//

import UIKit
import DITranquillity
@_exported import RxSwift

public func delayMT(_ time: Double = 0, block: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: block)
}

let container = DIContainer()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        container.append(part: NetworkDI.self)
        container.append(part: UI_DI.self)
        container.append(part: ModelsContainerDI.self)
        
        #if DEBUG
        if !container.makeGraph().checkIsValid(checkGraphCycles: true) {
            fatalError("invalid graph")
        }
        #endif
        
        container.initializeSingletonObjects()
        
        createRootVC()
   
        return true
    }
    
    var window: UIWindow?
    func createRootVC() {
        //TODO:
        
        let bounds = UIScreen.main.bounds
        window = UIWindow(frame: bounds)
        window?.rootViewController = Router(screen: .root).craeteViewController()
        window?.makeKeyAndVisible()
    }
}


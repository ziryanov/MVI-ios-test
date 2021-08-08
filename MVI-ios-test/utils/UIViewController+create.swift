//
//  UIViewController+create.swift
//  MVI-ios-test
//
//  Created by ziryanov on 07.08.2021.
//

import UIKit

extension UIViewController {
    
    @objc open class var storyboardName: String {
        return "Main" //default
    }
    
    class public func controllerFromStoryboard(storyboardName: String? = nil, storyboard: UIStoryboard? = nil, identifier: String? = nil) -> Self {
        return controllerFromStoryboardHelper(self, storyboardName: storyboardName, storyboard: storyboard, identifier: identifier)
    }
    
    class private func customStoryboard(storyboardName: String? = nil) -> UIStoryboard {
        let finalStoryboardName: String = storyboardName ?? self.storyboardName
        return UIStoryboard(name: finalStoryboardName, bundle: Bundle(for: self))
    }
    
    fileprivate class func controllerFromStoryboardHelper<T: UIViewController>(_ type: T.Type, storyboardName: String? = nil, storyboard: UIStoryboard? = nil, identifier: String? = nil) -> T {
        let finalStoryboard = storyboard ?? customStoryboard(storyboardName: storyboardName)
        let finalIdentifier: String = identifier ?? type.nameOfClass
        let controller = finalStoryboard.instantiateViewController(withIdentifier: finalIdentifier)
        // swiftlint:disable:next force_cast
        return controller as! T
    }
}

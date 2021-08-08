//
//  UIView+shake.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import UIKit

extension UIView {
    private func internalShake(mini: Bool, completion: (() -> Void)?) {
        let propertyAnimator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.3) {
            self.transform = CGAffineTransform(translationX: mini ? 10 : 20, y: 0)
        }

        propertyAnimator.addAnimations({
            self.transform = CGAffineTransform(translationX: 0, y: 0)
        }, delayFactor: 0.2)

        propertyAnimator.addCompletion { _ in
            completion?()
        }
        
        propertyAnimator.startAnimation()
    }
    
    func shake(completion: (() -> Void)? = nil) {
        internalShake(mini: false, completion: completion)
    }
    
    func miniShake(completion: (() -> Void)? = nil) {
        internalShake(mini: true, completion: completion)
    }
}

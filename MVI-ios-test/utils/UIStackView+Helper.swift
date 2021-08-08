//
//  UIStackView+Helper.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import UIKit

extension UIView {
    var topViewInStackView: UIView? {
        var superviews = [self]
        while !(superviews.last is UIStackView) {
            guard let superview = superviews.last?.superview else { return nil }
            superviews.append(superview)
        }
        guard let stackView = superviews.last as? UIStackView else { return nil }
        
        return superviews.reversed().dropFirst().first(where: { stackView.arrangedSubviews.contains($0) })
    }
    
    func stackViewAnimate(isHidden: Bool) {
        guard self.isHidden != isHidden else { return }
        UIView.animate(withDuration: 0.2) {
            self.isHidden = isHidden
            self.alpha = isHidden ? 0 : 1
        }
    }
}

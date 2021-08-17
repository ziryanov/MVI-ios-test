//
//  UIView+inspectable.swift
//  ReduxVMSample
//
//  Created by ziryanov on 16.10.2020.
//

import UIKit

extension UIView {
    
    @IBInspectable var inspCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable var inspCornerIsCircleOnlyFrame: Bool {
        get {
            return inspCornerRadius == min(bounds.size.width, bounds.size.height) / 2.0
        }
        set {
            if newValue {
                inspCornerRadius = min(bounds.size.width, bounds.size.height) / 2.0
            }
        }
    }
    @IBInspectable var inspBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    @IBInspectable var inspBorderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }    
}

//
//  NSObject+nameOfClass.swift
//  MVI-ios-test
//
//  Created by ziryanov on 07.08.2021.
//

import Foundation

extension NSObject {
    public class var nameOfClass: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
    
    public var nameOfClass: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last!
    }
}

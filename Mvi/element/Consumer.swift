//
//  Consumer.swift
//  MVI-ios-test
//
//  Created by ziryanov on 17.07.2021.
//

import Foundation

public protocol Consumer {
    associatedtype Consumable
    func accept(_ t: Consumable)
}

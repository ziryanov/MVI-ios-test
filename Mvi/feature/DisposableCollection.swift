//
//  DisposableCollection.swift
//  MVI-ios-test
//
//  Created by ziryanov on 17.07.2021.
//

import Foundation
import Combine

final class DisposableCollection: Cancellable {
    var array = [Cancellable]()
    
    func cancel() {
        array.forEach { $0.cancel() }
    }
    
    static func +=(lhs: DisposableCollection, rhs: Cancellable) {
        lhs.array.append(rhs)
    }
}

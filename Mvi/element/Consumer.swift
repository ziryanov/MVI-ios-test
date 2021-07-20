//
//  Consumer.swift
//  MVI-ios-test
//
//  Created by ziryanov on 17.07.2021.
//

import Foundation

open class Consumer<T> {
    func accept(_ t: T) {}
    
    init() {}
}

class BlockConsumer<T>: Consumer<T> {
    private let block: (T) -> Void
    
    init(_ block: @escaping (T) -> Void) {
        self.block = block
    }
    
    override func accept(_ t: T) {
        block(t)
    }
}

import Combine

extension Subject {
    func asConsumer() -> Consumer<Output> {
        BlockConsumer { [weak self] in
            self?.send($0)
        }
    }
}

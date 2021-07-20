//
//  Invoker.swift
//  MVI-ios-test
//
//  Created by ziryanov on 20.07.2021.
//

import Foundation

open class Invoker<A, B> {
    public init() {}

    open func invoke(_ t: A) -> B {
        fatalError()
    }
}

open class BlockInvoker<A, B>: Invoker<A, B> {
    private let block: (A) -> B
    
    public init(_ block: @escaping (A) -> B) {
        self.block = block
    }
    
    override open func invoke(_ t: A) -> B {
        block(t)
    }
}

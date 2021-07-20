//
//  Optional+let.swift
//  MVI-ios-test
//
//  Created by ziryanov on 17.07.2021.
//

import Foundation

extension Optional {
    func `let`<Out>(_ block: (Wrapped) -> Out) -> Out? {
        guard let strong = self else { return nil }
        return block(strong)
    }
}

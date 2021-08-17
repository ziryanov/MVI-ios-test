//
//  ParchmentState.swift
//  MVI-ios-test
//
//  Created by ziryanov on 16.08.2021.
//

import Foundation

struct ParchmentState {
    struct ParchmentSegment {
        let subsegments: [Router.Screen]
        var selectedIndex = 0
    }
    var segments: [ParchmentSegment]
    var activeChildIndex = 0
}

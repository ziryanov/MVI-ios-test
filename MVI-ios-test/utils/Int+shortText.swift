//
//  Int+shortDescription.swift
//  ReduxVMSample
//
//  Created by ziryanov on 25.10.2020.
//

import Foundation

extension Int {
    var shortText: String {
        let formatter = NumberFormatter()
        
        var number = Double(self)
        let units = ["", "K", "M", "G"]
        var unitIndex = 0
        while number > 1000, unitIndex < units.count - 1 {
            unitIndex += 1
            number /= 1000
        }
        if number < 100 {
            formatter.maximumFractionDigits = 1
        }
        return formatter.string(from: NSNumber(value: number))! + units[unitIndex]
    }
}

//
//  RxHolder.swift
//  MVI-ios-test
//
//  Created by ziryanov on 25.09.2021.
//

import Foundation

public enum RxHolder {
    static var mainScheduler: SchedulerType = MainScheduler.instance
}

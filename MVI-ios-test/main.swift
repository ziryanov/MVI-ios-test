//
//  main.swift
//  MVI-ios-test
//
//  Created by ziryanov on 25.09.2021.
//

import Foundation

private func delegateClassName() -> String? {
  return NSClassFromString("XCTestCase") == nil ? NSStringFromClass(AppDelegate.self) : nil
}

UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    delegateClassName()
)

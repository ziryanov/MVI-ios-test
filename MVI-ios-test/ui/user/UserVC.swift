//
//  UserVC.swift
//  MVI-ios-test
//
//  Created by ziryanov on 18.09.2021.
//

import Foundation

final class UserVC: DefaultTVC<UserFeature.News> {
    override class var storyboardName: String {
        return "User"
    }
}

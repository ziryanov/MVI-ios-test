//
//  UserVC.swift
//  MVI-ios-test
//
//  Created by ziryanov on 18.09.2021.
//

import Foundation

final class UserVC: TVC<UserFeature.News> {
    override class var storyboardName: String {
        return "User"
    }
}

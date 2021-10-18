//
//  PostsVC.swift
//  ReduxVMSample
//
//  Created by ziryanov on 16.10.2020.
//

import UIKit

final class PostsVC: DefaultTVC<PostsLoadingFinishedNews> {
    override class var storyboardName: String {
        return "Posts"
    }
}

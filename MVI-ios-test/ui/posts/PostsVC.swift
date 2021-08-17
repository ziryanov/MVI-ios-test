//
//  PostsVC.swift
//  ReduxVMSample
//
//  Created by ziryanov on 16.10.2020.
//

import UIKit

final class PostsVC: TVC, Consumer {
    override class var storyboardName: String {
        return "Posts"
    }
    
    typealias Consumable = PostsLoadingFinishedNews
    
    func accept(_ t: Consumable) { }
}

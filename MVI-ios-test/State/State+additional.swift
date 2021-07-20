//
//  StateWrapper.swift
//  ReduxVMSample
//
//  Created by ziryanov on 16.10.2020.
//

import Foundation

struct LikingPostQueue: Equatable {
    struct Request: Equatable {
        let postId: PostContainer.ModelId
        enum LikeOrDislike {
            case like, dislike
        }
        let likeOrDislike: LikeOrDislike
        var started: Bool
    }
    
    var requests = [Request]()
}

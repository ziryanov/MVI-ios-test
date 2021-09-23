//
//  UserState.swift
//  MVI-ios-test
//
//  Created by ziryanov on 17.09.2021.
//

import Foundation

struct UserState {
    var userBase: UsersContainer.BasicUserInfo
    var loadedUser: UsersContainer.Model? = nil

    enum Segment: CaseIterable {
        case posts
        case likes
    }
    var currentState = TableListState<Segment>.initialLoading
    var currentSegment: Segment = .posts
    
    var requestedPostIds = NotEmptyDictonary<Segment, [PostsContainer.ModelId]>(initial: [])
    var loadedPosts = NotEmptyDictonary<Segment, [PostsContainer.Model]>(initial: [])
}

extension UserState {
    func loadMoreEnabled(for segment: Segment) -> Bool {
        return requestedPostIds[segment].last != loadedUser?.postIds(for: segment).last
    }
}

extension UsersContainer.Model {
    func postIds(for segment: UserState.Segment) -> [PostsContainer.ModelId] {
        switch segment {
        case .posts:
            return posts
        case .likes:
            return likedPosts
        }
    }
    
    mutating func setPostIds(_ ids: [Int], for segment: UserState.Segment) {
        switch segment {
        case .posts:
            posts = ids
        case .likes:
            likedPosts = ids
        }
    }
}

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

    enum UserListState: Equatable {
        case initialLoading
        case loaded
        case failed(String)
        case refreshing
        case loadingMore([Segment: UUID])
    }
    var currentState = UserListState.initialLoading
    
    enum Segment: CaseIterable {
        case posts
        case likes
    }
    var loadedPosts = [PostsContainer.Model]()
    var loadedLikedPosts = [PostsContainer.Model]()
    
    var currentSegment: Segment = .posts
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

extension UserState {
    func loadedPosts(for segment: Segment) -> [PostsContainer.Model] {
        switch segment {
        case .posts:
            return loadedPosts
        case .likes:
            return loadedLikedPosts
        }
    }
    
    mutating func updatePosts(for segment: Segment, update: (inout [PostsContainer.Model]) -> Void) {
        switch segment {
        case .posts:
            update(&loadedPosts)
        case .likes:
            update(&loadedLikedPosts)
        }
    }
}

extension UserState.UserListState {
    func isReadyForLoadMore(for segment: UserState.Segment) -> Bool {
        switch self {
        case .loaded:
            return true
        case .loadingMore(let dict):
            return dict[segment] == nil
        default:
            return false
        }
    }
    
    func isLoadingMore(for segment: UserState.Segment, and uuid: UUID) -> Bool {
        switch self {
        case .loadingMore(let dict):
            return dict[segment] == uuid
        default:
            return false
        }
    }
    
    mutating func setLoadMore(for segment: UserState.Segment, uuid: UUID?) {
        var loadMoreInfo: [UserState.Segment: UUID]
        if case .loadingMore(let dict) = self {
            loadMoreInfo = dict
        } else {
            loadMoreInfo = .init()
        }
        loadMoreInfo[segment] = uuid
        if loadMoreInfo.isEmpty {
            self = .loaded
        } else {
            self = .loadingMore(loadMoreInfo)
        }
    }
}

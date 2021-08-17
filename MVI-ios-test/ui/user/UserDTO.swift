//
//  UserDTO.swift
//  ReduxVMSample
//
//  Created by ziryanov on 20.10.2020.
//

import Foundation

final class UserBasicDTO: Codable {
    var id: Int?
    var avatar: String?
    var username: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case avatar
        case username
    }
    
    init(id: Int?, avatar: String?, username: String?) {
        self.id = id
        self.avatar = avatar
        self.username = username
    }
}

final class UserDTO: Codable {
    var id: Int?
    var avatar: String?
    var username: String?
    var online: TimeInterval?
    
    var followersCount: Int?
    var followedByMe: Bool?
    
    var followers: [UserBasicDTO]?
    
    var additionalIndo: String?
    var posts: [PostsContainer.ModelId]?
    var likedPosts: [PostsContainer.ModelId]?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case avatar
        case username
        case online
        case followersCount = "followers_count"
        case followedByMe = "followed_by_me"
        case followers
        case posts = "posts"
        case likedPosts = "likes"
    }

    init(id: Int?, avatar: String?, username: String?, online: TimeInterval?, followersCount: Int?, followedByMe: Bool?, followers: [UserBasicDTO]?, additionalIndo: String?, posts: [PostsContainer.ModelId]?, likedPosts: [PostsContainer.ModelId]?) {
        self.id = id
        self.avatar = avatar
        self.username = username
        self.online = online
        self.followersCount = followersCount
        self.followedByMe = followedByMe
        self.followers = followers
        self.additionalIndo = additionalIndo
        self.posts = posts
        self.likedPosts = likedPosts
    }
}

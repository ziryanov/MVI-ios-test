//
//  UsersContainer.swift
//  ReduxVMSample
//
//  Created by ziryanov on 20.10.2020.
//

import Foundation

struct UsersContainer: ModelsContainer {
    typealias Model = User

    struct BasicUserInfo: Equatable, Hashable {
        var id: ModelId
        var avatar: String?
        var username: String
    }
    
    struct User: ModelWithId, Equatable, Hashable {
        typealias ModelId = Int
        var id: ModelId {
            basic.id
        }
        var basic: BasicUserInfo
        
        enum Online: Equatable, Hashable {
            case online
            case was(TimeInterval)
            
            init(_ value: TimeInterval) {
                if value < 60 {
                    self = .online
                } else {
                    self = .was(value)
                }
            }
        }
        var online: Online

        var followersCount: Int
        var followedByMe: Bool
        
        var followers: [UsersContainer.BasicUserInfo]
        
        var additionalIndo: String?
        var posts: [ModelId]
        var likedPosts: [ModelId]
    }
}

extension UsersContainer.BasicUserInfo {
    init?(dto: UserBasicDTO) {
        guard let id = dto.id,
              let username = dto.username
        else { return nil }
        
        self.id = id
        self.avatar = dto.avatar
        self.username = username
    }
}

extension UsersContainer.User {
    init?(userId: UsersContainer.ModelId, dto: UserDTO) {
        guard let id = dto.id, id == userId,
              let username = dto.username,
              let online = dto.online,
              let followersCount = dto.followersCount,
              let followedByMe = dto.followedByMe,
              let posts = dto.posts
        else { return nil }
        
        self.basic = UsersContainer.BasicUserInfo(id: userId, avatar: dto.avatar, username: username)
        self.online = .init(online)
        self.followersCount = followersCount
        self.followedByMe = followedByMe
        let followers = dto.followers?.compactMap(UsersContainer.BasicUserInfo.init)
        self.followers = followers ?? []
        self.additionalIndo = dto.additionalIndo
        self.posts = posts
        self.likedPosts = dto.likedPosts ?? []
    }
}

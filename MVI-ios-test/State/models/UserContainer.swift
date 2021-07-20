//
//  UserContainer.swift
//  ReduxVMSample
//
//  Created by ziryanov on 20.10.2020.
//

import Foundation

struct UserContainer: Equatable {
    typealias ModelId = Int
    typealias Model = User
    
    struct BasicUserInfo: Equatable, Hashable {
        var id: ModelId
        var avatar: String?
        var username: String
    }
    
    struct User: Equatable, Hashable {
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
        
        var followers: [UserContainer.BasicUserInfo]
        
        var additionalIndo: String?
        var posts: [PostContainer.ModelId]
        var likedPosts: [PostContainer.ModelId]
    }
    
    var models = [ModelId: Model]()
    
    func model(with id: ModelId) -> Model? {
        return models[id]
    }
    
    mutating func updateModel(with id: ModelId, model: Model) {
        models[id] = model
    }
}

//extension UserContainer.BasicUserInfo {
//    init?(dto: UserBasicDTO) {
//        guard let id = dto.id,
//              let username = dto.username
//        else { return nil }
//        
//        self.id = id
//        self.avatar = dto.avatar
//        self.username = username
//    }
//}
//
//extension UserContainer.User {
//    init?(userId: UserContainer.ModelId, dto: UserDTO) {
//        guard let id = dto.id, id == userId,
//              let username = dto.username,
//              let online = dto.online,
//              let followersCount = dto.followersCount,
//              let followedByMe = dto.followedByMe,
//              let posts = dto.posts
//        else { return nil }
//        
//        self.basic = UserContainer.BasicUserInfo(id: userId, avatar: dto.avatar, username: username)
//        self.online = .init(online)
//        self.followersCount = followersCount
//        self.followedByMe = followedByMe
//        let followers = dto.followers?.compactMap(UserContainer.BasicUserInfo.init)
//        self.followers = followers ?? []
//        self.additionalIndo = dto.additionalIndo
//        self.posts = posts
//        self.likedPosts = dto.likedPosts ?? []
//    }
//}

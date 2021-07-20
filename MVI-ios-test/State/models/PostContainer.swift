//
//  PostContainer.swift
//  ReduxVMSample
//
//  Created by ziryanov on 20.10.2020.
//

import Foundation

struct ImageWithRatio: Equatable, Hashable {
    let image: String
    let ratio: Double
}

struct PostContainer: Equatable {
    typealias ModelId = Int
    typealias Model = Post
    
    struct Post: Equatable, Hashable {
        let id: ModelId
        let userBasic: UserContainer.BasicUserInfo
        
        let date: Date
        let bodyText: String?
        let bodyImage: ImageWithRatio?
        
        var likesCount: Int
        var likedByMe: Bool
        
        var repostsCount: Int
        var repostedByMe: Bool
        
        let canComment: Bool
        var commentsCount: Int
        var commentedByMe: Bool
        
        let viewsCount: Int
    }
    
    var models = [ModelId: Model]()
    
    func model(with id: ModelId) -> Model? {
        return models[id]
    }
    
    mutating func updateModel(with id: ModelId, model: Model) {
        models[id] = model
    }
    
    mutating func updateModels(_ models: [Model]?) {
        for model in models ?? [] {
            self.models[model.id] = model
        }
    }
}

//extension PostContainer.Post {
//    init?(dto: PostDTO) {
//        guard let id = dto.id,
//              let userId = dto.userId,
//              let username = dto.username,
//              let date = dto.date,
//              let likesCount = dto.likesCount,
//              let likedByMe = dto.likedByMe,
//
//              let repostsCount = dto.repostsCount,
//              let repostedByMe = dto.repostedByMe,
//
//              let canComment = dto.canComment,
//              let commentsCount = dto.commentsCount,
//              let commentedByMe = dto.commentedByMe,
//
//              let viewsCount = dto.viewsCount else {
//            return nil
//        }
//        self.id = id
//        self.userBasic = .init(id: userId, avatar: dto.avatar, username: username)
//
//        self.date = date
//        self.bodyText = dto.bodyText
//        if let image = dto.bodyImage {
//            self.bodyImage = .init(image: image, ratio: dto.bodyImageRatio ?? 1)
//        } else {
//            self.bodyImage = nil
//        }
//
//        self.likesCount = likesCount
//        self.likedByMe = likedByMe
//
//        self.repostsCount = repostsCount
//        self.repostedByMe = repostedByMe
//
//        self.canComment = canComment
//        self.commentsCount = commentsCount
//        self.commentedByMe = commentedByMe
//
//        self.viewsCount = viewsCount
//    }
//}

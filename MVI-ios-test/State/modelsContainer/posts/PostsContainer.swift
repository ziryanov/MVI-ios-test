//
//  PostsContainer.swift
//  ReduxVMSample
//
//  Created by ziryanov on 20.10.2020.
//

import Foundation
import CoreGraphics

struct PostsContainer: ModelsContainerProtocol {
    typealias Model = Post
    
    var models = [Int: Post]()

    struct Post: ModelWithId {
        typealias ModelId = Int
        let id: ModelId
        let userBasic: UsersContainer.BasicUserInfo
        
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
}

extension PostsContainer.Post {
    init?(dto: PostDTO) {
        guard let id = dto.id,
              let userId = dto.userId,
              let username = dto.username,
              let date = dto.date,
              let likesCount = dto.likesCount,
              let likedByMe = dto.likedByMe,

              let repostsCount = dto.repostsCount,
              let repostedByMe = dto.repostedByMe,

              let canComment = dto.canComment,
              let commentsCount = dto.commentsCount,
              let commentedByMe = dto.commentedByMe,

              let viewsCount = dto.viewsCount else {
            return nil
        }
        self.id = id
        self.userBasic = .init(id: userId, avatar: dto.avatar, username: username)

        self.date = date
        self.bodyText = dto.bodyText
        if let image = dto.bodyImage {
            self.bodyImage = .init(image: image, ratio: dto.bodyImageRatio ?? 1)
        } else {
            self.bodyImage = nil
        }

        self.likesCount = likesCount
        self.likedByMe = likedByMe

        self.repostsCount = repostsCount
        self.repostedByMe = repostedByMe

        self.canComment = canComment
        self.commentsCount = commentsCount
        self.commentedByMe = commentedByMe

        self.viewsCount = viewsCount
    }
}

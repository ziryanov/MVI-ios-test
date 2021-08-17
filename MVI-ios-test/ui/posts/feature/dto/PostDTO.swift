//
//  PostDTO.swift
//  ReduxVMSample
//
//  Created by ziryanov on 16.10.2020.
//

import Foundation
import CoreGraphics

final class PostDTO: Codable {
    var id: Int?
    
    var userId: Int?
    var avatar: String?
    var username: String?
    var date: Date?
    
    var bodyText: String?
    var bodyImage: String?
    var bodyImageRatio: CGFloat?
    
    var likesCount: Int?
    var likedByMe: Bool?
    
    var repostsCount: Int?
    var repostedByMe: Bool?
    
    var canComment: Bool?
    var commentsCount: Int?
    var commentedByMe: Bool?
    
    var general: Bool?
    
    var viewsCount: Int?

    private enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case avatar
        case username
        case date
        case bodyText = "text"
        case bodyImage = "image"
        case bodyImageRatio = "image_ratio"
        case likesCount = "likes_count"
        case likedByMe = "liked"
        case repostsCount = "reposts_count"
        case repostedByMe = "reposted"
        case canComment = "can_comment"
        case commentsCount = "comments_count"
        case commentedByMe = "commented"
        case general = "general"
        case viewsCount = "views_count"
    }
    
    internal init(id: Int?, userId: Int?, avatar: String?, username: String?, date: Date?, bodyText: String?, bodyImage: String?, bodyImageRatio: CGFloat?, likesCount: Int?, likedByMe: Bool?, repostsCount: Int?, repostedByMe: Bool?, canComment: Bool?, commentsCount: Int?, commentedByMe: Bool?, viewsCount: Int?, general: Bool?) {
        self.id = id
        self.userId = userId
        self.avatar = avatar
        self.username = username
        self.date = date
        self.bodyText = bodyText
        self.bodyImage = bodyImage
        self.bodyImageRatio = bodyImageRatio
        self.likesCount = likesCount
        self.likedByMe = likedByMe
        self.repostsCount = repostsCount
        self.repostedByMe = repostedByMe
        self.canComment = canComment
        self.commentsCount = commentsCount
        self.commentedByMe = commentedByMe
        self.viewsCount = viewsCount
        self.general = general
    }
}

extension PostDTO: CustomDebugStringConvertible {
    var debugDescription: String {
        return "PostDTO(id: \(id!))"
    }
}

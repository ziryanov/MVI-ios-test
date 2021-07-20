//
//  API.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation
import Moya

enum API {
    case sessionCheck
    case checkIdentifierAvailability(identifier: String)
    case signIn(identifier: String, password: String)
    case signUp(identifier: String, password: String)
    case logout

    case getProfile
    case getFeedIds
    case getInterestingIds
    case getFirstTwo
    case getPosts(ids: [PostContainer.ModelId])

    case getImportantPosts(perPage: Int, after: PostContainer.ModelId?)

    case getFollowers(userId: UserContainer.ModelId, perPage: Int, after: UserContainer.ModelId?)

    case likeDislike(postId: PostContainer.ModelId, like: Bool)
    case loadUser(userId: UserContainer.ModelId)
}

extension API: TargetType {
    var baseURL: URL {
        return URL(string: "localhost")!
    }

    var path: String {
        switch self {
        case .sessionCheck:
            return "session_check"
        case .checkIdentifierAvailability:
            return "check_identifier"
        case .signIn:
            return "signin"
        case .signUp:
            return "signup"
        case .logout:
            return "logout"

        case .getProfile:
            return "profile"
        case .likeDislike(_, let like):
            return like ? "like" : "dislike"
        case .loadUser:
            return "user"
        case .getFeedIds:
            return "feed"
        case .getInterestingIds:
            return "interesting"
        case .getPosts:
            return "posts"
        case .getFirstTwo:
            return "posts2"
        case .getImportantPosts:
            return "important"
        case .getFollowers:
            return "followers"
        }
    }

    var method: Moya.Method {
        switch self {
        case .signIn, .logout, .signUp, .likeDislike:
            return .post
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }

//    var sampleData: Data {
//        switch self {
//        case .sessionCheck:
//            let result = MockServer.shared.checkSession() ? "{\"success\": true}" : ""
//            return result.data(using: .utf8)!
//        case .logout:
//            MockServer.shared.logout()
//            return "".data(using: .utf8)!
//        case .signIn(let identifier, let password):
//            if let res = MockServer.shared.signIn(identifier: identifier, password: password) {
//                return try! JSONEncoder().encode(res)
//            }
//            return "".data(using: .utf8)!
//        case .signUp(let identifier, let password):
//            if let res = MockServer.shared.signUp(identifier: identifier, password: password) {
//                return try! JSONEncoder().encode(res)
//            }
//            return "".data(using: .utf8)!
//        case .getProfile:
//            if let res = MockServer.shared.getProfile() {
//                return try! JSONEncoder().encode(res)
//            }
//            return "error".data(using: .utf8)!
//        case .likeDislike(let id, let like):
//            MockServer.shared.likeDislikePost(id: id, like: like)
//            return "success".data(using: .utf8)!
//        case .checkIdentifierAvailability(let identifier):
//            if identifier.hasPrefix("+1") {
//                return "{\"not_available\": true}".data(using: .utf8)!
//            } else {
//                return "{\"not_available\": false}".data(using: .utf8)!
//            }
//        case .loadUser(let id):
//            return MockServer.shared.user(id: id)
//        case .getFeedIds:
//            return MockServer.shared.feedIds()
//        case .getInterestingIds:
//            return MockServer.shared.interestingIds()
//        case .getPosts(let ids):
//            return MockServer.shared.getPosts(ids: ids)
//        case .getFirstTwo:
//            return MockServer.shared.firstTwo()
//        case .getImportantPosts(let perPage, let after):
//            return MockServer.shared.getGeneralPosts(perPage: perPage, after: after)
//        case .getFollowers(let userId, let perPage, let after):
//            return MockServer.shared.getFollowers(userId: userId, perPage: perPage, after: after)
//        }
//    }

    var task: Task {
        switch self {
        case .sessionCheck, .logout, .getFeedIds, .getInterestingIds, .getFirstTwo, .getProfile:
            return .requestPlain
        case .checkIdentifierAvailability(let identifier):
            return .requestParameters(parameters: ["identifier": identifier], encoding: JSONEncoding.default)
        case .signIn(let identifier, let password):
            return .requestParameters(parameters: ["identifier": identifier, "password": password], encoding: JSONEncoding.default)
        case .signUp(let identifier, let password):
            return .requestParameters(parameters: ["identifier": identifier, "password": password], encoding: JSONEncoding.default)
        case .likeDislike(let id, _):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.default)
        case .loadUser(let id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.default)
        case .getPosts(let ids):
            return .requestParameters(parameters: ["ids": ids], encoding: URLEncoding.default)
        case .getImportantPosts(let perPage, let after):
            var dict = ["per_page": perPage]
            if let after = after {
                dict["after_id"] = after
            }
            return .requestParameters(parameters: dict, encoding: URLEncoding.default)
        case .getFollowers(let userId, let perPage, let after):
            var dict = ["user_id": userId, "per_page": perPage]
            if let after = after {
                dict["after_id"] = after
            }
            return .requestParameters(parameters: dict, encoding: URLEncoding.default)
        }
    }

    var headers: [String : String]? {
        return nil
    }
}

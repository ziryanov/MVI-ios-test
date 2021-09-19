//
//  MockServer.swift
//  ReduxVMSample
//
//  Created by ziryanov on 22.10.2020.
//

import Foundation
import CoreGraphics

final class MockServer {
    
    static let shared = MockServer()
    
    func feedIds() -> Data {
        let ids = posts.map { $0.id! }
        return try! JSONSerialization.data(withJSONObject: ids, options: [])
    }
    func interestingIds() -> Data {
        let ids = posts.filter({ $0.id! % 3 == 1 }).shuffled().map { $0.id! }
        return try! JSONSerialization.data(withJSONObject: ids, options: [])
    }
    func getPosts(ids: [Int]) -> Data {
        let posts = self.posts.filter({ ids.contains($0.id!) })
        return try! JSONEncoder().encode(posts)
    }
    func firstTwo() -> Data {
        let ids = posts.prefix(2).map { $0.id! }
        return try! JSONSerialization.data(withJSONObject: ids, options: [])
    }
    func user(id: Int) -> Data {
        let users = self.users.first(where: { $0.id == id })!
        return try! JSONEncoder().encode(users)
    }
    func getGeneralPosts(perPage: Int, after: PostsContainer.ModelId?) -> Data {
        let result = posts.filter({ $0.general == true })
        var afterIndex = 0
        if let after = after, let index = result.firstIndex(where: { $0.id == after }) {
            afterIndex = index
        }
        return try! JSONEncoder().encode(Array(result.suffix(from: afterIndex).prefix(perPage)))
    }
    
    func getFollowers(userId: UsersContainer.ModelId, perPage: Int, after: UsersContainer.ModelId?) -> Data {
        let result = follows.filter { $0.followId == userId }
        var afterIndex = 0
        if let after = after, let index = result.firstIndex(where: { $0.followerId == after }) {
            afterIndex = index
        }
        let followers = result.suffix(from: afterIndex).prefix(perPage)
            .map { follow in users.first(where: { $0.id == follow.followerId })! }
        
        return try! JSONEncoder().encode(followers)
    }
    
    private var users: [UserDTO]
    private var posts: [PostDTO]
    
    struct MockFollowerDTO: Codable {
        let followerId: UsersContainer.ModelId
        let followId: UsersContainer.ModelId
    }
    private var follows: [MockFollowerDTO]
    
    private let version = "1.7.8"
    
    @UserDefault("loggedUserId")
    var loggedUserId: Int?
    
    struct RegisteredUser: Codable {
        let id: Int
        let identifier: String
        let password: String
    }
    private var registeredUser: [RegisteredUser]
    
    enum MockServerErrors: Error {
        case signUpAlreadyregistered
    }
    
    func signUp(identifier: String, password: String) throws -> UserDTO {
        guard !registeredUser.contains(where: { $0.identifier == identifier }) else {
            throw MockServerErrors.signUpAlreadyregistered
        }
        let userIds = users.map(\.id)
        let alreadyregisterdIds = registeredUser.map(\.id)
        let freeIds = Set(userIds).subtracting(Set(alreadyregisterdIds))
        let newUserId = freeIds.randomElement()!!
        
        let user = users.first(where: { $0.id == newUserId })!
        loggedUserId = user.id
        
        let registered = RegisteredUser(id: newUserId, identifier: identifier, password: password)
        registeredUser.append(registered)
        saveRegistered()
        
        return user
    }
    
    func signIn(identifier: String, password: String) -> UserDTO? {
        guard let registered = registeredUser.first(where: { $0.identifier == identifier && $0.password == password }),
              let user = users.first(where: { $0.id == registered.id }) else { return nil }
        loggedUserId = user.id
        return user
    }
    
    func checkSession() -> Bool {
        return loggedUserId != nil
    }
    
    func logout() {
        loggedUserId = nil
    }
    
    func getProfile() -> UserDTO? {
        guard registeredUser.first(where: { $0.id == loggedUserId }) != nil else { return nil }
        return users.first(where: { $0.id == loggedUserId })
    }
    
    func likeDislikePost(id: PostsContainer.ModelId, like: Bool) {
        let post = posts.first(where: { $0.id == id })!
        guard post.likedByMe != like else {
            return
        }
        
        let meUser = getProfile()
        
        if like {
            meUser?.likedPosts?.append(id)
            post.likesCount! += 1
            post.likedByMe = true
        } else {
            if let index = meUser?.likedPosts?.firstIndex(of: id) {
                meUser?.likedPosts?.remove(at: index)
                post.likesCount! -= 1
            }
            post.likedByMe = false
        }
        saveUsers()
        savePosts()
    }
    
    func followUnfUser(id: UsersContainer.ModelId) {
        if let index = follows.firstIndex(where: { $0.followerId == loggedUserId && $0.followId == id }) {
            follows.remove(at: index)
        } else {
            follows.append(MockFollowerDTO(followerId: loggedUserId!, followId: id))
        }
        saveFollows()
    }
    
    private init() {
        if let version = UserDefaults.standard.string(forKey: "mock_version"), version == self.version, let usersData = UserDefaults.standard.data(forKey: "mock_users"), let postsData = UserDefaults.standard.data(forKey: "mock_posts"), let followsData = UserDefaults.standard.data(forKey: "mock_follows"), let registeredUserData = UserDefaults.standard.data(forKey: "mock_registered") {
            users = try! JSONDecoder().decode([UserDTO].self, from: usersData)
            posts = try! JSONDecoder().decode([PostDTO].self, from: postsData)
            follows = try! JSONDecoder().decode([MockFollowerDTO].self, from: followsData)
            registeredUser = try! JSONDecoder().decode([RegisteredUser].self, from: registeredUserData)
        } else {
            var userId = 0
            func getUserId() -> Int {
                userId += 1
                return userId
            }
            var postId = 10000
            func getNextPostId() -> Int {
                postId -= 1
                return postId
            }
            var date = Date().addingTimeInterval(-60)
            func getDate() -> Date {
                date.addTimeInterval(30 * TimeInterval(1 + arc4random_uniform(4)))
                return date
            }
            
            let txt = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
            let words = txt.components(separatedBy: " ")
            
            func getText() -> String {
                let wordsCount = Int(10 + arc4random_uniform(UInt32(words.count - 10)))
                return words.shuffled().prefix(wordsCount).joined(separator: " ")
            }
            func getImage() -> (String, CGFloat)? {
                if arc4random_uniform(3) == 1 {
                    let id = arc4random_uniform(100)
                    let ratio = CGFloat((3 + arc4random_uniform(7))) / 5
                    return ("https://picsum.photos/id/\(id)/300/\(Int(300 * ratio))", ratio)
                } else {
                    return nil
                }
            }
            
            func generatePost(user: UserDTO) -> PostDTO {
                let image = getImage()
                let id = getNextPostId()
                return PostDTO(id: id, userId: user.id, avatar: user.avatar, username: user.username, date: getDate(), bodyText: "\(id) " + getText(), bodyImage: image?.0, bodyImageRatio: image?.1, likesCount: 0, likedByMe: false, repostsCount: Int(arc4random_uniform(3)), repostedByMe: false, canComment: arc4random_uniform(5) < 4, commentsCount: Int(arc4random_uniform(3)), commentedByMe: false, viewsCount: Int(arc4random_uniform(100_000_000)), general: arc4random_uniform(2) == 1)
            }
            
            func generateUser() -> UserDTO {
                let id = getUserId()
                var userName = words.randomElement()
                if arc4random_uniform(4) == 1 {
                    userName += " " + words.randomElement()
                }
                let online: TimeInterval
                if arc4random_uniform(2) == 1 {
                    online = 0
                } else {
                    online = TimeInterval(arc4random_uniform(2) * 60 * 60 + arc4random_uniform(5) * 60 + arc4random_uniform(30))
                }

                return UserDTO(id: id, avatar: "https://i.pravatar.cc/150?img=\(id)", username: userName, online: online, followersCount: 0, followedByMe: false, followers: [], additionalIndo: words.randomElement(), posts: [], likedPosts: [])
            }
            
            self.registeredUser = []
            
            let usersCount = 20
            let users = (0..<usersCount).map { _ in generateUser() }
            self.users = users
            
            let postsCount = 500
            self.posts = (0..<postsCount).map { _ in
                let user = users.randomElement()
                let post = generatePost(user: user)
                user.posts?.append(post.id!)
                return post
            }
            
            var allFollows = [MockFollowerDTO]()

            let firstUser = users.first!
            for post in posts {
                guard arc4random_uniform(2) == 1 else { continue }
                post.likesCount = post.likesCount! + 1
                firstUser.likedPosts?.append(post.id!)
            }
            
            let otherUsers = users.suffix(from: 1)
            firstUser.followersCount = otherUsers.count
            otherUsers.forEach {
                allFollows.append(MockFollowerDTO(followerId: $0.id!, followId: firstUser.id!))
            }
            firstUser.followers?.append(contentsOf: otherUsers.map({ $0.basic() }).prefix(20))
            
            for user in otherUsers {
                posts[0].likesCount = posts[0].likesCount! + 1
                user.likedPosts!.append(posts[0].id!)
                
                for post in posts.suffix(from: 1) {
                    guard arc4random_uniform(5) == 1 else { continue }
                    post.likesCount = post.likesCount! + 1
                    user.likedPosts!.append(post.id!)
                }
                
                for user2 in users {
                    guard user2.id != user.id, arc4random_uniform(3) == 1 else { continue }
                    user.followersCount = user.followersCount! + 1
                    if user.followers!.count <= 20 {
                        user.followers?.append(user2.basic())
                    }
                    allFollows.append(MockFollowerDTO(followerId: user2.id!, followId: user.id!))
                }
            }
            
            follows = allFollows
            
            save()
            loggedUserId = nil
        }
    }
    
    private func save() {
        UserDefaults.standard.setValue(version, forKey: "mock_version")
        saveUsers()
        savePosts()
        saveFollows()
    }
    
    private func savePosts() {
        let postsData = try! JSONEncoder().encode(posts)
        UserDefaults.standard.setValue(postsData, forKey: "mock_posts")
        UserDefaults.standard.synchronize()
    }
    
    private func saveFollows() {
        let followsData = try! JSONEncoder().encode(follows)
        UserDefaults.standard.setValue(followsData, forKey: "mock_follows")
        UserDefaults.standard.synchronize()
    }
    
    private func saveUsers() {
        let usersData = try! JSONEncoder().encode(users)
        UserDefaults.standard.setValue(usersData, forKey: "mock_users")
        UserDefaults.standard.synchronize()
    }
    
    private func saveRegistered() {
        let data = try! JSONEncoder().encode(registeredUser)
        UserDefaults.standard.setValue(data, forKey: "mock_registered")
        UserDefaults.standard.synchronize()
    }
}

extension Array {
    fileprivate func randomElement() -> Element {
        self[Int(arc4random_uniform(UInt32(count)))]
    }
}

extension UserDTO {
    fileprivate func basic() -> UserBasicDTO {
        return UserBasicDTO(id: id, avatar: avatar, username: username)
    }
}

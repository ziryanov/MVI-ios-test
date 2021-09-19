//
//  UserVCModule.swift
//  MVI-ios-test
//
//  Created by ziryanov on 18.09.2021.
//

import Foundation
import DeclarativeTVC
import DITranquillity

enum UserVCModule {
    typealias ViewController = UserVC
    
    class Presenter: PresenterBase<ViewController, UserFeature> {
        override func _createView() -> ViewController {
            return ViewController.controllerFromStoryboard()
        }
        
        private let likingPostFeature: LikingPostFeature = container.resolve()
        private let routerFeature: RouterFeature = container.resolve()
        override func _props(for state: State) -> ViewController.Props {
            var rows = [CellAnyModel]()

            let user = state.loadedUser
            rows.append(UserHeaderCellVM(userBasic: state.userBase, fullUser: user, followPressed: Command() {

            }, messagePressed: Command() {

            }))
            
            if let user = user {
                rows.append(UserFollowersTitleCellVM(followersCount: user.followersCount, selectCommand: Command() {

                }))
                if !user.followers.isEmpty {
                    rows.append(UserFollowersCellVM(users: user.followers, userPressed: CommandWith<UsersContainer.BasicUserInfo>(action: { [unowned routerFeature] in
                        routerFeature.accept(.push(.user($0)))
                    })))
                }
                
                let segments: [UserState.Segment] = [.posts, .likes]
                let index = segments.firstIndex(of: state.currentSegment)!
                let names = segments.map { "\($0.title) \(user.postIds(for: $0).count)" }
                rows.append(SegmentedCellVM(segments: names, selectedIndex: index, changeSegment: CommandWith<Int>() { [unowned feature] in
                    feature.accept(.changeSegment(segments[$0]))
                }))
                
                let posts = state.loadedPosts(for: state.currentSegment)
                if posts.isEmpty {
                    rows.append(LoadingCellVM())
                }
                rows.append(contentsOf: posts.map { post in
                    PostCellVM(post: post,
                               userPressed: Command(action: { [unowned routerFeature] in
                                routerFeature.accept(.push(.user(post.userBasic)))
                               }),
                               likePressed: Command(action: { [unowned likingPostFeature] in
                                likingPostFeature.accept(.init(model: post))
                               }),
                               commentPressed: Command(action: {}),
                               repostPressed: Command(action: {}),
                               selectCommand: Command(action: {}))
                })
                if state.currentState.isReadyForLoadMore(for: state.currentSegment) {
                    rows.append(LoadingCellVM())
                }
            } else {
                rows.append(LoadingCellVM())
            }
            
            return TVC.Props(tableModel: TableModel(rows: rows),
                             refreshing: state.currentState == .refreshing)
            }
        
        override func _actions(for state: State) -> ViewController.Actions {
            .init(
                refresh: Command(action: { [unowned feature] in
                    feature.accept(.refresh)
                }),
                loadMore: Command(action: { [unowned feature] in
                    feature.accept(.loadMore)
                }))
        }
    }
    
    final class DI: DIPart {
        static func load(container: DIContainer) {
            container.register { UserFeature.init(base: arg($0), network: $1, postsContainerFeature: $2, usersContainerFeature: $3) }
                .lifetime(.objectGraph)
        }
    }
}

extension UserState.Segment {
    var title: String {
        switch self {
        case .posts:
            return "Posts"
        case .likes:
            return "Liked posts"
        }
    }
}

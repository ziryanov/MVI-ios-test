//
//  PostsVCModule.swift
//  ReduxVMSample
//
//  Created by ziryanov on 16.10.2020.
//

import Foundation
import DeclarativeTVC
import DITranquillity

enum PostsVCModule {
    typealias ViewController = PostsVC
    
    class Presenter<PostsState: PostsStateProtocol, PostsFeature: FeatureProtocol>: PresenterBase<ViewController, PostsFeature> where PostsFeature.News == ViewController.Consumable, PostsFeature.State == PostsState, PostsFeature.Consumable == TableViewWish {
        override func createView() -> ViewController {
            return ViewController.controllerFromStoryboard()
        }
        
        override func props(for state: State) -> ViewController.Props {
            var rows = [CellAnyModel]()

            if state.currentState == .initialLoading {
                rows.append(LoadingCellVM())
            } else {
                rows.append(contentsOf: state.loaded.map { post in
                    PostCellVM(post: post,
                               userPressed: Command(action: {
//                                let userState = UserScreenState(userBase: post.userBasic)
//                                trunk.dispatch(NavigationContainerScreen.Push(stateWrapper: stateWrapper, screen: userState))
                               }),
                               likePressed: Command(action: {
//                                trunk.dispatch(PostContainer.Post.LikeDislike(postId: post.id))
                               }),
                               commentPressed: Command(action: {}),
                               repostPressed: Command(action: {}),
                               selectCommand: Command(action: {}))
                })
                if state.loadMoreEnabled {
                    rows.append(LoadingCellVM())
                }
            }
            
            return TVC.Props(tableModel: TableModel(rows: rows),
                             refreshing: state.currentState == .refreshing)
            
            }
        
        override func actions(for state: State) -> TVC.Actions {
            .init(refresh: Command(action: { [unowned feature] in
                feature.accept(.refresh)
            }),
            loadMore: Command(action: { [unowned feature] in
                feature.accept(.loadMore)
            }))
        }
    }
    
    final class PresenterGeneral: Presenter<GeneralPostsState, PostsGeneralFeature> {}
    final class Presenter2Step: Presenter<Posts2StepState, Post2StepFeature> {}

    final class DI: DIPart {
        static func load(container: DIContainer) {
            container.register { Post2StepFeature.init(source: arg($0), containerFeature: $1, network: $2) }
                .lifetime(.objectGraph)
            container.register(Presenter2Step.init)
                .lifetime(.objectGraph)
            
            container.register(PostsGeneralFeature.init)
                .lifetime(.objectGraph)
            container.register(PresenterGeneral.init)
                .lifetime(.objectGraph)
        }
    }
}

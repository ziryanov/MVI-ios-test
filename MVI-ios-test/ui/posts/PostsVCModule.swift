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
    
    class Presenter<PostsState: EntitiesState, PostsFeature: Feature>: PresenterBase<ViewController, PostsFeature> where PostsState.Model == PostsContainer.Post, PostsState.LoadingMoreOptions == LoadingMoreDefault, PostsFeature.News == ViewController.Consumable, PostsFeature.State == PostsState, PostsFeature.Consumable == TableViewWishDefault {
        override func _createView() -> ViewController {
            return ViewController.controllerFromStoryboard()
        }
        
        private let likingPostFeature: LikingPostFeature = container.resolve()
        private let routerFeature: RouterFeature = container.resolve()
        override func _props(for state: State) -> ViewController.Props {
            var rows = [CellAnyModel]()

            if state.currentState == .initialLoading {
                rows.append(LoadingCellVM())
            } else {
                print("after first refresh")
                rows.append(contentsOf: state.loaded.map { post in
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
                if state.loadMoreEnabled(for: .more) {
                    rows.append(LoadingCellVM())
                }
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
                    print("loadin more!")
                    feature.accept(.loadMore(.more))
                }))
        }
    }
    
    final class PresenterGeneral: Presenter<GeneralPostsState, PostsGeneralFeature> {}
    final class Presenter2Step: Presenter<Posts2StepState, Post2StepFeature> {}

    final class DI: DIPart {
        static func load(container: DIContainer) {
            container.register { Post2StepFeature.init(source: arg($0), containerFeature: $1, network: $2) }
                .lifetime(.objectGraph)
            container.register(PostsGeneralFeature.init)
                .lifetime(.objectGraph)
        }
    }
}

//
//  LikingPostFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 16.09.2021.
//

import Foundation
import RxSwift

class LikingPostFeature: BaseFeature<LikingPostFeature.LikeOrDislikeWish, LikingPostFeature.State, LikingPostFeature.News, LikingPostFeature.InnerPart> {
    
    struct LikeOrDislikeWish {
        let model: PostsContainer.Model
    }
    
    struct State {
        struct Request {
            enum LikeOrDislike {
                case like, dislike
                
                func opposite() -> Self {
                    switch self {
                    case .like:
                        return .dislike
                    case .dislike:
                        return .like
                    }
                }
            }
            var likeOrDislike: LikeOrDislike
            var needRevert = false
        }
        var requests = [PostsContainer.ModelId: Request]()
    }
    
    struct News {
        let updatedModel: PostsContainer.Model
    }
    
    init(network: Network, containerFeature: PostsContainerFeature) {
        let innerPart = InnerPart(network: network)
        super.init(initialState: State(), innerPart: innerPart)
        
        news
            .subscribe(onNext: {
                containerFeature.accept(wish: .init(updated: [$0.updatedModel], updater: innerPart))
            })
            .disposed(by: disposeBag)
    }
    
    class InnerPart: FeatureInnerPart {
        typealias Wish = LikingPostFeature.LikeOrDislikeWish
        typealias State = LikingPostFeature.State
        typealias News = LikingPostFeature.News
        
        private let network: Network
        fileprivate init(network: Network) {
            self.network = network
        }
        
        enum Action {
            case initialChange(PostsContainer.Model)
            case checkQueue(PostsContainer.Model)
            case startRequest(PostsContainer.ModelId, State.Request)
            case checkIfNeedRevert(PostsContainer.ModelId)
        }

        enum Effect {
            case initialChange(PostsContainer.Model)
            
            case setNeedRevertRequest(PostsContainer.ModelId, Bool)
            case addRequest(PostsContainer.ModelId, State.Request)
            case finishRequest(PostsContainer.ModelId)
            case deleteRequest(PostsContainer.ModelId)
        }
        
        func action(from wish: Wish) -> Action {
            .initialChange(wish.model)
        }

        func actor<Holder>(from action: Action, stateHolder: Holder) -> Observable<Effect> where Holder : StateHolder, State == Holder.State {
            switch action {
            case .initialChange(let model):
                var copy = model
                if model.likedByMe {
                    copy.likesCount -= 1
                } else {
                    copy.likesCount += 1
                }
                copy.likedByMe = !model.likedByMe
                return .just(.initialChange(copy))
            case .checkQueue(let model):
                let id = model.id
                return Observable<Effect>.createSimple { [weak stateHolder] in
                    if let existed = stateHolder?.state.requests[id] {
                        return .setNeedRevertRequest(id, !existed.needRevert)
                    } else {
                        return .addRequest(id, .init(likeOrDislike: model.likedByMe ? .like : .dislike))
                    }
                }
            case .startRequest(let id, let request):
                let effect = Effect.finishRequest(id)
                return network
                    .request(.likeDislike(postId: id, like: request.likeOrDislike == .like))
                    .map { _ in effect }
                    .catchErrorJustReturn(effect)
                    .asObservable()
            case .checkIfNeedRevert(let id):
                return Observable<Effect>.createSimple { [weak stateHolder] in
                    if let request = stateHolder?.state.requests[id], request.needRevert {
                        return .addRequest(id, .init(likeOrDislike: request.likeOrDislike.opposite()))
                    } else {
                        return .deleteRequest(id)
                    }
                }
            }
        }

        func reduce(with effect: Effect, state: inout State) {
            switch effect {
            case .addRequest(let id, let request):
                state.requests[id] = request
            case .setNeedRevertRequest(let id, let needRevert):
                state.requests[id]?.needRevert = needRevert
            case .deleteRequest(let id):
                state.requests[id] = nil
            case .initialChange, .finishRequest:
                break
            }
        }
        
        func postProcessor(oldState: State, action: Action, effect: Effect, state: State) -> Action? {
            switch effect {
            case .initialChange(let model):
                return .checkQueue(model)
            case .addRequest(let id, let request):
                return .startRequest(id, request)
            case .finishRequest(let id):
                return .checkIfNeedRevert(id)
            case .setNeedRevertRequest, .deleteRequest:
                break
            }
            return nil
        }
        
        func news(from action: Action, effect: Effect, state: State) -> News? {
            if case .initialChange(let model) = effect {
                return .init(updatedModel: model)
            }
            return nil
        }
    }

}

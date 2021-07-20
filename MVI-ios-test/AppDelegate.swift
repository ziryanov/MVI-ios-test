//
//  AppDelegate.swift
//  MVI-ios-test
//
//  Created by ziryanov on 17.07.2021.
//

import UIKit
import Combine

public func delayMT(_ time: Double = 0, block: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: block)
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
//    class Feature1: BaseFeature<Feature1.Wish, Feature1.Action, Feature1.Effect, Feature1.State, Feature1.News> {
//
//        init(initial: Int) {
//            super.init(initialState: State(counter: initial), wishToAction: .init() { .wish($0) }, actor: .init() { state, action in
//                let current = state.counter
//                let new: Int
//                switch action {
//                case .wish(let wish):
//                    switch wish {
//                    case .increment:
//                        new = current + 1
//                    case .decrement:
//                        new = current - 1
//                    case .reset:
//                        new = initial
//                    }
//                }
//
//                return Just(.setCounter(new))
//                    .delay(for: 0.5, scheduler: DispatchQueue.main)
//                    .eraseToAnyPublisher()
//            }, reducer: { state, effect in
//                var clone = state
//                switch effect {
//                case .setCounter(let new):
//                    clone.counter = new
//                }
//                return clone
//            }, newsPublisher: { (action, effect, state) in
//                if state.counter == 10 {
//                    return .reach10
//                }
//                return nil
//            })
//        }
//
//        struct State {
//            var counter: Int
//        }
//
//        enum Wish {
//            case increment, decrement, reset
//        }
//
//        enum Action {
//            case wish(Wish)
//        }
//
//        enum Effect {
//            case setCounter(Int)
//        }
//
//        enum News {
//            case reach10
//        }
//    }
//
//    var feature1: Feature1!
//    var feature2: Feature1!
//
//    var cancels = [AnyCancellable]()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        Middlewares.configurations.append(MiddlewareConfiguration(condition: WrappingCondition.always, factory: { LogingMiddleware() }))
//
//        feature1 = Feature1(initial: 5)
//        feature2 = Feature1(initial: 11)
//
//        feature1.sink(receiveValue: {
//            NSLog("1 \($0)")
//        })
//        .store(in: &cancels)
//
//        feature1.news.sink {
//            NSLog("1n \($0)")
//        }
//        .store(in: &cancels)
//
//        feature1.sink(receiveValue: {
//            NSLog("11 \($0)")
//        })
//        .store(in: &cancels)
//
//        feature2.sink(receiveValue: {
//            NSLog("2 \($0)")
//        })
//        .store(in: &cancels)
//
//        feature2.news.sink {
//            NSLog("2n \($0)")
//        }
//        .store(in: &cancels)
//
//        delayMT(0.5) {
//            NSLog("event1")
//            self.feature1.accept(.increment)
//            self.feature2.accept(.decrement)
//        }
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


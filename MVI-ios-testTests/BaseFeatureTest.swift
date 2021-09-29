//
//  BaseFeatureTest.swift
//  MVI-ios-testTests
//
//  Created by ziryanov on 24.09.2021.
//

import XCTest
import RxTest
@testable import MVI_ios_test

class BaseFeatureTest: XCTestCase {

    class SimpleFeature: BaseFeature<SimpleFeature.Wish, Int, SimpleFeature.News, SimpleFeature.InnerPart> {
        enum Wish {
            case w1, w2
        }
        enum News {
            case n1, n3
        }
        
        init(scheduler: TestScheduler, immideatlyBootstrapper: Bool) {
            super.init(initialState: 0, innerPart: InnerPart(scheduler: scheduler, immideatlyBootstrapper: immideatlyBootstrapper))
        }
        
        class InnerPart: FeatureInnerPart {
            let scheduler: TestScheduler
            let immideatlyBootstrapper: Bool
            init(scheduler: TestScheduler, immideatlyBootstrapper: Bool) {
                self.scheduler = scheduler
                self.immideatlyBootstrapper = immideatlyBootstrapper
            }
            
            enum Events {
                case actionFromWish(Wish)
                case actor(Action)
                case reduce(Effect)
                case pp(Effect)
                case news(Effect)
            }
            
            typealias Wish = SimpleFeature.Wish
            typealias News = SimpleFeature.News
            typealias State = Int
            enum Action {
                case a1, a2, a3
            }
            enum Effect {
                case e1, e2, e3
            }
            
            static func delay(for action: Action) -> TestTime {
                switch action {
                case .a1: return 30
                case .a2: return 40
                case .a3: return 50
                }
            }
            static let bootstrapperDelay: TestTime = 70
            
            func bootstrapper() -> Observable<Action> {
                return scheduler.createColdObservable(delay: immideatlyBootstrapper ? 0 : InnerPart.bootstrapperDelay, just: Action.a3)
            }
            
            func action(from wish: Wish) -> Action {
                switch wish {
                case .w1: return .a1
                case .w2: return .a2
                }
            }
            
            func actor<Holder>(from action: Action, stateHolder: Holder) -> Observable<Effect> where Holder : StateHolder, State == Holder.State {
                let delay = InnerPart.delay(for: action)
                switch action {
                case .a1: return scheduler.createColdObservable(delay: delay, just: Effect.e1)
                case .a2: return scheduler.createColdObservable(delay: delay, just: Effect.e2)
                case .a3: return scheduler.createColdObservable(delay: immideatlyBootstrapper ? 0 : delay, just: Effect.e3)
                }
            }
            
            func reduce(with effect: Effect, state: inout State) {
                switch effect {
                case .e1: state += 1
                case .e2: state += 10
                case .e3: state += 100
                }
            }
            
            func news(from action: Action, effect: Effect, state: State) -> News? {
                switch effect {
                case .e1: return .n1
                case .e2: return nil
                case .e3: return .n3
                }
            }
            
            func postProcessor(oldState: State, action: Action, effect: Effect, state: State) -> Action? {
                switch effect {
                case .e3: return .a1
                default: return nil
                }
            }
        }
    }
    
    private func testSF(immideatlyBootstrapper: Bool) {
        let scheduler = TestScheduler(initialClock: 0, simulateProcessingDelay: false)
        RxHolder.mainScheduler = scheduler

        let feature = SimpleFeature(scheduler: scheduler, immideatlyBootstrapper: immideatlyBootstrapper)
        
        let result = scheduler.createObserver(Int.self)
        var subscription: Disposable! = nil
        
        scheduler.scheduleAt(0) { subscription = feature.subscribe(result) }
        scheduler.scheduleAt(200) { feature.accept(.w1) }
        scheduler.scheduleAt(300) { feature.accept(.w2) }
        
        scheduler.scheduleAt(500) {
            let bootstrapperFirstPartE3Delay = immideatlyBootstrapper ? 0 : SimpleFeature.InnerPart.bootstrapperDelay + SimpleFeature.InnerPart.delay(for: .a3)
            let bootstrapperSecondPartE1Delay = bootstrapperFirstPartE3Delay + SimpleFeature.InnerPart.delay(for: .a1)
            
            let shouldBe: [Recorded<Event<Int>>] = [
                .next(0, 0),
                .next(bootstrapperFirstPartE3Delay, 100),
                .next(bootstrapperSecondPartE1Delay, 101),
                .next(200 + SimpleFeature.InnerPart.delay(for: .a1), 102),
                .next(300 + SimpleFeature.InnerPart.delay(for: .a2), 112)
            ]

            XCTAssert(result.events == shouldBe)
            subscription.dispose()
        }
        
        scheduler.start()
    }
    
    func test_SimpleFeature() throws {
        testSF(immideatlyBootstrapper: false)
    }
    
    func test_SimpleFeature_ImmideatlyBootstrapper() throws {
        testSF(immideatlyBootstrapper: true)
    }
    
    func testNews(immideatlyBootstrapper: Bool) {
        let scheduler = TestScheduler(initialClock: 0, simulateProcessingDelay: false)
        RxHolder.mainScheduler = scheduler

        let feature = SimpleFeature(scheduler: scheduler, immideatlyBootstrapper: immideatlyBootstrapper)

        
        let result = scheduler.createObserver(SimpleFeature.News.self)
        var subscription: Disposable! = nil
        
        scheduler.scheduleAt(0) { subscription = feature.news.subscribe(result) }
        scheduler.scheduleAt(200) { feature.accept(.w1) }
        scheduler.scheduleAt(300) { feature.accept(.w2) }
        
        scheduler.scheduleAt(500) {
            let bootstrapperFirstPartE3Delay = immideatlyBootstrapper ? 0 : SimpleFeature.InnerPart.bootstrapperDelay + SimpleFeature.InnerPart.delay(for: .a3)
            let bootstrapperSecondPartE1Delay = bootstrapperFirstPartE3Delay + SimpleFeature.InnerPart.delay(for: .a1)
            
            let shouldBe: [Recorded<Event<SimpleFeature.News>>] = [
                .next(bootstrapperFirstPartE3Delay, .n3),
                .next(bootstrapperSecondPartE1Delay, .n1),
                .next(200 + SimpleFeature.InnerPart.delay(for: .a1), .n1)
            ]

            XCTAssert(result.events == shouldBe)
            subscription.dispose()
        }
        
        scheduler.start()
    }
    
    func test_SimpleFeature_News() {
        testNews(immideatlyBootstrapper: false)
    }
    
    func test_SimpleFeature_News_ImmideatlyBootstrapper() {
        testNews(immideatlyBootstrapper: true)
    }
}

extension TestScheduler {
    func createColdObservable<Element>(delay: TestTime, just: Element) -> Observable<Element> {
        createColdObservable([.next(delay, just), .completed(delay)]).asObservable()
    }
}

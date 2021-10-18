//
//  TrendsFeatureTest.swift
//  MVI-ios-testTests
//
//  Created by ziryanov on 25.09.2021.
//

import XCTest
import RxTest
@testable import MVI_ios_test
import Moya

class TrendsFeatureTest: XCTestCase {

    func test_Trends_SimpleState() throws {
        let scheduler = TestScheduler(initialClock: 0, simulateProcessingDelay: true)
        RxHolder.mainScheduler = scheduler

        let tr1 = TrendDTO(id: "1", name: "name1")
        let tr2 = TrendDTO(id: "2", name: "name2")
        let tr3 = TrendDTO(id: "3", name: "name3")
        var trends = [tr1, tr2]
        var counter = 0
        let network = NetworkMock { api in
            print("counter = \(counter) \(trends.map({ $0.id! }))")
            counter += 1
            let data = try! JSONEncoder().encode(trends)
            let response = Response(statusCode: 200, data: data)
            return .just(response)
        }
        
        var feature: TrendsFeature! = TrendsFeature(network: network)
        
        var subscription: Disposable! = nil
        let result = scheduler.createObserver(TrendsFeature.State.self)
        
        scheduler.scheduleAt(0) { subscription = feature.subscribe(result) }
        scheduler.scheduleAt(8) {
            trends = [tr2, tr1]
        }
        scheduler.scheduleAt(15) {
            trends = [tr2, tr1, tr3]
        }
        scheduler.scheduleAt(17) {
            trends = [tr2, tr1]
        }
        scheduler.scheduleAt(20) {
            print(result.events.map({ "\($0.value.element!) @ \($0.time)" }).joined(separator: "\n"))
            
            XCTAssert(result.lastElement(at: 0).trends.isEmpty)
            XCTAssert(result.lastElement(at: 0).lastUpdatedId == -1)
            
            //all lastUpdatedId lags by 2 because of simulateProcessingDelay in TestScheduler
            
            XCTAssert(result.lastElement(at: 2).trends == [tr1, tr2])
            XCTAssert(result.lastElement(at: 2).trends[0].previousPosition == nil)
            XCTAssert(result.lastElement(at: 2).lastUpdatedId == 0)
            
            XCTAssert(result.lastElement(at: 3).trends == [tr1, tr2])
            XCTAssert(result.lastElement(at: 3).lastUpdatedId == 1)
            
            XCTAssert(result.lastElement(at: 4).trends == [tr2, tr1])
            XCTAssert(result.lastElement(at: 4).lastUpdatedId == 2)

            subscription.dispose()
            feature = nil
        }
        
        scheduler.start()
    }
}

extension TrendDTO {
    static func == (lhs: TrendsFeature.State.Trend, rhs: TrendDTO) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}

extension Array where Element == TrendDTO {
    static func == (lhs: [TrendsFeature.State.Trend], rhs: [TrendDTO]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for (l, r) in zip(lhs, rhs) {
            guard (l == r) else { return false }
        }
        return true
    }
}

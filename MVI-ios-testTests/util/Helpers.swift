//
//  Helpers.swift
//  MVI-ios-testTests
//
//  Created by ziryanov on 25.09.2021.
//

import Foundation
@testable import MVI_ios_test
import Moya
import RxTest

class FeatureMock<Wish, News>: WishConsumer, NewsProvider {
    let news: Observable<News>
    let wishBlock: ((Wish) -> Void)?
    init(wish: ((Wish) -> Void)?, news: Observable<News> = .empty()) {
        self.wishBlock = wish
        self.news = news
    }
    
    func accept(wish: Wish) {
        wishBlock?(wish)
    }
}

class NetworkMock: NetworkType {
    private let block: (API) -> Single<Response>
    init(_ block: @escaping (API) -> Single<Response>) {
        self.block = block
    }
    
    func request(_ token: API) -> Single<Response> {
        block(token)
    }
}

struct ScheduleTime {
    private var counter = 0
    
    mutating func next() -> Int {
        counter += 10
        return counter
    }
}

extension TestableObserver {
    func element(at: Int) -> Element? {
        events[at].value.element
    }
    
    func lastElement(at time: TestTime) -> Element {
        events.last(where: { $0.time == time })!.value.element!
    }
    
    func haveElement(at time: TestTime, where block: (Element) -> Bool) -> Bool {
        for event in events where event.time == time {
            if block(event.value.element!) {
                return true
            }
        }
        return false
    }
}

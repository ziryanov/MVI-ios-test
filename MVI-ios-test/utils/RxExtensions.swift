//
//  RxExtensions.swift
//  MVI-ios-test
//
//  Created by ziryanov on 31.07.2021.
//

import Foundation
import RxSwift

extension Completable {
    public static func mergeDelayError(_ array: [Completable]) -> Completable {
        return Observable
            .zip(array.map { $0.asObservable().materialize() } )
            .map { events -> RxSwift.Event<Never> in
                if let error = events.first(where: { $0.error != nil }) {
                    return .error(error.error ?? RxError.unknown)
                } else {
                    return .completed
                }
            }
            .dematerialize()
            .asCompletable()
    }
}

extension Maybe {
    static func just(_ elem: Element, if block: @autoclosure @escaping () -> Bool) -> Maybe<Element> {
        return Maybe<Element>.create { observer in
            if block() {
                observer(.success(elem))
            } else {
                observer(.completed)
            }
            return Disposables.create()
        }
    }
}

extension Observable {
    static func createSimple(_ block: @escaping () -> Element) -> Observable<Element> {
        return Observable<Element>.create { observer in
            observer.onNext(block())
            observer.onCompleted()
            return Disposables.create()
        }
    }
}

extension Maybe {
    static func createSimple(_ block: @escaping () -> Element?) -> Maybe<Element> {
        return Maybe<Element>.create { observer in
            if let value = block() {
                observer(.success(value))
            } else {
                observer(.completed)
            }
            return Disposables.create()
        }
    }
}

fileprivate var disposeBagContext: UInt8 = 0
fileprivate var disposeBagsCollectionContext: UInt8 = 0
extension Reactive where Base: AnyObject {
    func synchronizedBag<T>( _ action: () -> T) -> T {
        objc_sync_enter(base)
        let result = action()
        objc_sync_exit(base)
        return result
    }
}

public extension Reactive where Base: AnyObject {
    
    /// a unique DisposeBag that is related to the Reactive.Base instance only for Reference type
    var disposeBag: DisposeBag {
        get {
            return synchronizedBag {
                if let bag = objc_getAssociatedObject(base, &disposeBagContext) as? DisposeBag {
                    return bag
                }
                let bag = DisposeBag()
                objc_setAssociatedObject(base, &disposeBagContext, bag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return bag
            }
        }
        set {
            synchronizedBag {
                objc_setAssociatedObject(base, &disposeBagContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    func disposeBag(tag: String) -> DisposeBag {
        return synchronizedBag {
            var bagsCollection = objc_getAssociatedObject(base, &disposeBagsCollectionContext) as? [String: DisposeBag] ?? [String: DisposeBag]()
            let bag = DisposeBag()
            bagsCollection[tag] = bag
            objc_setAssociatedObject(base, &disposeBagsCollectionContext, bagsCollection, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bag
        }
    }
}

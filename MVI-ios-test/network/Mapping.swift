//
//  Mapping.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation
import Moya
import RxSwift

extension PrimitiveSequenceType where Trait == SingleTrait, Element == Response {
    public func map<T: Decodable>(to: T.Type, rootKeyPath: String? = nil) -> Single<T> {
        return map { result -> T in
            let data: Data
            if let rootKeyPath = rootKeyPath {
                var dict: Any? = try result.mapJSON()
                dict = (dict as? [String: Any])?[keyPath: rootKeyPath]
                guard let json = dict else {
                    throw ApiError.mappingFailed
                }
                data = try JSONSerialization.data(withJSONObject: json, options: [])
            } else {
                data = result.data
            }
            let mapped = try JSONDecoder().decode(to, from: data)
            return mapped
        }
    }

//    public func map<T: Decodable>(to: [T].Type, rootKeyPath: String? = nil) -> Single<[T]> {
//        return map { result -> [T] in
//            let data: Data
//            if let rootKeyPath = rootKeyPath {
//                var dict: Any? = try result.mapJSON()
//                dict = (dict as? [String: Any])?[keyPath: rootKeyPath]
//                guard let json = dict else {
//                    throw ApiError.mappingFailed
//                }
//                data = try JSONSerialization.data(withJSONObject: json, options: [])
//            } else {
//                data = result.data
//            }
//            let mapped = try JSONDecoder().decode(to, from: data)
//            return mapped
//        }
//    }
}

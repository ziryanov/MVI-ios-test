//
//  Mapping.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation
import Moya
import Combine
extension AnyPublisher where Output == Response {
//    public func map<T: Mappable>(toElement: T.Type, rootKeyPath: String? = nil) -> Single<T> {
//        return map { result -> T in
//            var dict: Any? = try result.mapJSON()
//            if let rootKeyPath = rootKeyPath {
//                dict = (dict as? [String: Any])?[keyPath: rootKeyPath]
//            }
//            guard dict != nil, let mapped = Mapper<T>().map(JSONObject: dict) else { throw ApiError.mappingFailed }
//            return mapped
//        }
//    }
//
//    public func map<T: Mappable>(toArray: T.Type, rootKeyPath: String? = nil) -> Single<[T]> {
//        return map { result -> [T] in
//            var dict: Any? = try result.mapJSON()
//            if let rootKeyPath = rootKeyPath {
//                dict = (dict as? [String: Any])?[keyPath: rootKeyPath]
//            }
//            guard dict != nil, let mapped = Mapper<T>().mapArray(JSONObject: dict) else { throw ApiError.mappingFailed }
//            return mapped
//        }
//    }

    public func map<T: Decodable>(to: T.Type, rootKeyPath: String? = nil) -> Publishers.TryMap<AnyPublisher<Response, Failure>, T> {
        return tryMap { result -> T in
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

//    public func map<T: Decodable>(to: [T].Type, rootKeyPath: String? = nil) -> Publishers.TryMap<AnyPublisher<Response, Failure>, [T]> {
//        return tryMap { result -> [T] in
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

//private protocol AnyDecodable { }
//
//private extension Response {
//    public func map<T: Decodable>(to: T.Type, rootKeyPath: String? = nil) throws -> [T] {
//        
//    }
//    
//    public func map<T: Decodable>(to: [T].Type, rootKeyPath: String? = nil) throws -> [T] {
//        let data: Data
//        if let rootKeyPath = rootKeyPath {
//            var dict: Any? = try mapJSON()
//            dict = (dict as? [String: Any])?[keyPath: rootKeyPath]
//            guard let json = dict else {
//                throw ApiError.mappingFailed
//            }
//            data = try JSONSerialization.data(withJSONObject: json, options: [])
//        } else {
//            data = self.data
//        }
//        let mapped = try JSONDecoder().decode(to, from: data)
//        return mapped
//    }
//}

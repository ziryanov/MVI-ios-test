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
    func map<T: Decodable>(to: T.Type, rootKeyPath: String? = nil) -> Single<T> {
        return map { result -> T in
            let data: Data
            if let rootKeyPath = rootKeyPath {
                let rootDict: Any? = try result.mapJSON()
                let dict = (rootDict as? [String: Any])?[keyPath: rootKeyPath]
                guard let json = dict else {
                    throw ApiError(reason: .mappingFailed, serverError: NetworkHelper.findServerError(errorSearchDict: rootDict))
                }
                data = try JSONSerialization.data(withJSONObject: json, options: [])
            } else {
                data = result.data
            }
            guard let mapped = try? JSONDecoder().decode(to, from: data) else {
                throw ApiError(reason: .mappingFailed, serverError: NetworkHelper.findServerError(response: result))
            }
            return mapped
        }
    }
}

enum NetworkHelper {
    static func findServerError(errorSearchDict: Any?) -> String? {
        return (errorSearchDict as? [String: Any])?["error"] as? String
    }
    
    static func findServerError(response: Response) -> String? {
        let rootDict = try? response.mapJSON()
        return (rootDict as? [String: Any])?["error"] as? String
    }
}

//
//  API+work.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation
import Moya
import Combine

final class Network {
    private let provider: MoyaProvider<API>
    
    init(provider: MoyaProvider<API>) {
        self.provider = provider
    }

    func request(_ token: API) -> AnyPublisher<Response, MoyaError> {
        return provider.requestPublisher(token).filterSuccessfulStatusCodes()
    }
}

public enum ApiError: Swift.Error, CustomDebugStringConvertible {
    case mappingFailed
}

public extension ApiError {
    var debugDescription: String {
        switch self {
        case .mappingFailed:
            return "Mapping failed"
        }
    }
}

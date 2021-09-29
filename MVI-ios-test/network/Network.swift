//
//  API+work.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation
import Moya
import RxSwift

protocol NetworkType {
    func request(_ token: API) -> Single<Response>
}

final class Network: NetworkType {
    private let provider: MoyaProvider<API>
   
    init(provider: MoyaProvider<API>) {
        self.provider = provider
    }

    func request(_ token: API) -> Single<Response> {
        return provider.rx.request(token).filterSuccessfulStatusCodes()
    }
}

struct ApiError: Swift.Error {
    static let cancelled = ApiError(reason: .cancelled)
    
    init(reason: ApiError.Reason, serverError: String? = nil) {
        self.reason = reason
        self.serverError = serverError
    }
    
    enum Reason {
        case mappingFailed
        case cancelled
        case internalLogicError
    }
    
    let reason: Reason
    let serverError: String?
}

//
//  API+work.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation
import Moya
import RxSwift

final class Network {
    private let provider: MoyaProvider<API>
   
    init(provider: MoyaProvider<API>) {
        self.provider = provider
    }

    func request(_ token: API) -> Single<Response> {
        return provider.rx.request(token).filterSuccessfulStatusCodes()
    }
}

struct ApiError: Swift.Error {
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

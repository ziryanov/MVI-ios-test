//
//  NetworkDI.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation
import Moya
import DITranquillity

final class NetworkDI: DIPart {
    
    public static func load(container: DIContainer) {
        container.register(Session.init)
            .lifetime(.single)
        
        container.register { MoyaProvider<API>(stubClosure: MoyaProvider.delayedStub(0.2), plugins: []) } //NetworkLoggerPlugin()
            .lifetime(.single)
        container.register(Network.init)
            .lifetime(.single)
    }
}

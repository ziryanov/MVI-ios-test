//
//  Session.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation

final class Session {
    var hasCookies: Bool? {
        return MockServer.shared.loggedUserId != nil
    }
}

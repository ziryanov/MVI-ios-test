//
//  Session.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation

struct Session {
    @UserDefault("loggedId")
    static var loggedId: UserContainer.ModelId?
    
    var hasCookies: Bool {
        return Session.loggedId != nil
    }
}

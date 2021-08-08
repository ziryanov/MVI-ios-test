//
//  SessionState.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation

enum SessionState {
    case checking
    case waitingAuth
    case loadingProfile
    case signedIn
}

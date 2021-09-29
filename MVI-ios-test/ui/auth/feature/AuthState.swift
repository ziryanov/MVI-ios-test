//
//  AuthState.swift
//  MVI-ios-test
//
//  Created by ziryanov on 29.07.2021.
//

import Foundation

struct AuthScreenState {
    enum SignInOrSignUp {
        case signIn
        case signUp
    }
    var signInOrSignUp = SignInOrSignUp.signIn

    var requestInProgress = false
        
    struct Text {
        var value: String = ""
        
        enum ValidationState {
            case waiting
            case validationInProgress(UUID)
            case valid
            case invalid(Error)
            
            var isValidationInProgress: Bool {
                if case .validationInProgress = self {
                    return true
                }
                return false
            }
        }
        var validationState: ValidationState = .waiting
        
        var validationError: String? {
            if case let .invalid(error) = validationState {
                return error.localizedDescription
            }
            return nil
        }
    }
    var identifier = Text()
    var password = Text()
    
    enum TextType: CaseIterable {
        case identifier, password
    }
    var editingText: TextType? = nil
    
    var acceptPolicy = false
}

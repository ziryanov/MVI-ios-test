//
//  AuthCredentialsValidator.swift
//  MVI-ios-test
//
//  Created by ziryanov on 31.07.2021.
//

import Foundation

struct AuthValidatorError: Error, LocalizedError, ExpressibleByStringLiteral {
    let errorDescription: String?
    init(stringLiteral value: String) {
        errorDescription = value
    }
}

protocol AuthCredentialsValidatorType {
    func validateIdentifier(_ value: String?, signInOrSignUp: AuthScreenState.SignInOrSignUp) -> Single<AuthValidatorError?>
    func validatePassword(_ value: String?) -> Single<AuthValidatorError?>
}

struct AuthCredentialsValidator: AuthCredentialsValidatorType {
    private let network: NetworkType
    init(network: NetworkType) {
        self.network = network
    }
    
    private func isValidEmail(_ string: String) -> Bool {
        return string.contains("@")
    }
    
    private func isValidPhone(_ string: String) -> Bool {
        return string.hasPrefix("+")
    }
    
    func validateIdentifier(_ value: String?, signInOrSignUp: AuthScreenState.SignInOrSignUp) -> Single<AuthValidatorError?> {
        guard let identifier = value, !identifier.isEmpty else {
            return .just("Enter email or phone")
        }
        
        let isValidEmail = self.isValidEmail(identifier)
        let isValidPhone = self.isValidPhone(identifier)
        
        guard isValidEmail || isValidPhone else {
            return .just("Input valid email or phone")
        }
        
        switch signInOrSignUp {
        case .signIn:
            return .just(nil)
        case .signUp:
            return network
                .request(.checkIdentifierAvailability(identifier: identifier))
                .map(to: CheckIdentifierAvailabilityDTO.self)
                .map { $0.notAvailable == true }
                .catchError { _ in Single.just(false) }
                .flatMap {
                    if $0 {
                        let error: AuthValidatorError = isValidPhone ? "Phone is already registered" : "Email is already registered"
                        return .just(error)
                    }
                    return .just(nil)
                }
        }
    }
    
    func validatePassword(_ value: String?) -> Single<AuthValidatorError?> {
        guard let identifier = value, identifier.count > 6 else {
            return .just(AuthValidatorError("Password to short"))
        }
        return .just(nil)
    }
}

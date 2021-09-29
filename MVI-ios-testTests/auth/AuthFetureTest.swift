//
//  AuthFetureTest.swift
//  MVI-ios-testTests
//
//  Created by ziryanov on 25.09.2021.
//

import XCTest
@testable import MVI_ios_test
import RxTest
import Moya

class AuthFetureTest: XCTestCase {
    
    class AuthCredentialsValidatorMock: AuthCredentialsValidatorType {
        private let scheduler: TestScheduler
        
        var validIdentifier: String? = nil
        var validPassword: String? = nil
        
        init(scheduler: TestScheduler, failed: Bool) {
            self.scheduler = scheduler
            if failed {
                validIdentifier = UUID().uuidString
                validPassword = UUID().uuidString
            }
        }
        func validateIdentifier(_ value: String?, signInOrSignUp: AuthScreenState.SignInOrSignUp) -> Single<AuthValidatorError?> {
            Single.createSimple {
                (self.validIdentifier == nil || self.validIdentifier == value) ? nil : "error"
            }
        }
        func validatePassword(_ value: String?) -> Single<AuthValidatorError?> {
            Single.createSimple {
                (self.validPassword == nil || self.validPassword == value) ? nil : "error"
            }
        }
    }

    func test_AuthFeature_Identifier_Validation() throws {
        let sessionFeatureConsumer = FeatureMock<SessionFeature.Wish, Void>(wish: { _ in })
        let network = NetworkMock { api in .error(ApiError.cancelled) }
        
        let scheduler = TestScheduler(initialClock: 0, simulateProcessingDelay: true)
        RxHolder.mainScheduler = scheduler
        
        let feature = AuthFeature(sessionFeatureConsumer: sessionFeatureConsumer, network: network, authCredentialsValidator: AuthCredentialsValidatorMock(scheduler: scheduler, failed: true))
        
        let result = scheduler.createObserver(AuthScreenState.self)
        var subscription: Disposable! = nil
        
        scheduler.scheduleAt(0) { subscription = feature.subscribe(result) }
        scheduler.scheduleAt(10) { feature.accept(.startInput(.identifier)) }
        scheduler.scheduleAt(20) { feature.accept(.changeInput(.identifier, "qw")) }
        scheduler.scheduleAt(30) { feature.accept(.changeInput(.identifier, "qwe")) }
        scheduler.scheduleAt(40) { feature.accept(.finishInput) }
        
        scheduler.scheduleAt(100) {
            XCTAssert(result.lastElement(at: 10).editingText == .identifier)
            XCTAssert(result.lastElement(at: 10).identifier.validationState == .waiting)
            XCTAssert(!result.haveElement(at: 10, where: { $0.identifier.validationState.isValidationInProgress }))
            
            XCTAssert(result.lastElement(at: 20).editingText == .identifier)
            XCTAssert(result.lastElement(at: 20).identifier.value == "qw")
            XCTAssert(result.lastElement(at: 20).identifier.validationState == .waiting)
            XCTAssert(!result.haveElement(at: 20, where: { $0.identifier.validationState.isValidationInProgress }))
            
            XCTAssert(result.lastElement(at: 30).editingText == .identifier)
            XCTAssert(result.lastElement(at: 30).identifier.value == "qwe")
            XCTAssert(result.lastElement(at: 30).identifier.validationState == .waiting)
            XCTAssert(!result.haveElement(at: 30, where: { $0.identifier.validationState.isValidationInProgress }))
            
            XCTAssert(result.lastElement(at: 40).editingText == nil)
            XCTAssert(result.lastElement(at: 40).identifier.validationError == "error")
            XCTAssert(result.haveElement(at: 40, where: { $0.identifier.validationState.isValidationInProgress }))
            XCTAssert(!result.haveElement(at: 40, where: { $0.password.validationState.isValidationInProgress }))
            
            subscription.dispose()
        }
        
        scheduler.start()
    }
    
    func test_AuthFeature_ChangeInputValidations() throws {
        let sessionFeatureConsumer = FeatureMock<SessionFeature.Wish, Void>(wish: { _ in })
        let network = NetworkMock { api in .error(ApiError.cancelled) }
        
        let scheduler = TestScheduler(initialClock: 0, simulateProcessingDelay: true)
        RxHolder.mainScheduler = scheduler
        
        let feature = AuthFeature(sessionFeatureConsumer: sessionFeatureConsumer, network: network, authCredentialsValidator: AuthCredentialsValidatorMock(scheduler: scheduler, failed: true))
        
        let result = scheduler.createObserver(AuthScreenState.self)
        var subscription: Disposable! = nil
        
        scheduler.scheduleAt(0) { subscription = feature.subscribe(result) }
        scheduler.scheduleAt(10) { feature.accept(.startInput(.identifier)) }
        scheduler.scheduleAt(20) { feature.accept(.changeInput(.identifier, "qw")) }
        scheduler.scheduleAt(30) { feature.accept(.startInput(.password)) }
        
        scheduler.scheduleAt(100) {
            XCTAssert(result.lastElement(at: 30).editingText == .password)
            XCTAssert(result.lastElement(at: 30).identifier.validationError == "error")
            
            subscription.dispose()
        }
        
        scheduler.start()
    }
    
    func test_AuthFeature_ValidateBeforeRequest() throws {
        let sessionFeatureConsumer = FeatureMock<SessionFeature.Wish, Void>(wish: { _ in })
        let network = NetworkMock { api in .error(ApiError(reason: .internalLogicError, serverError: "server")) }
        
        let scheduler = TestScheduler(initialClock: 0, simulateProcessingDelay: true)
        RxHolder.mainScheduler = scheduler
        
        let validator = AuthCredentialsValidatorMock(scheduler: scheduler, failed: false)
        validator.validIdentifier = "1"
        let feature = AuthFeature(sessionFeatureConsumer: sessionFeatureConsumer, network: network, authCredentialsValidator: validator)

        var subscription1: Disposable! = nil
        var subscription2: Disposable! = nil
        let stateResult = scheduler.createObserver(AuthScreenState.self)
        let newsResult = scheduler.createObserver(AuthFeature.News.self)
        
        scheduler.scheduleAt(0) {
            subscription1 = feature.subscribe(stateResult)
            subscription2 = feature.news.subscribe(newsResult)
        }
        scheduler.scheduleAt(10) {
            feature.accept(.startRequest)
        }
        scheduler.scheduleAt(20) {
            validator.validIdentifier = nil
            validator.validPassword = "2"
            feature.accept(.startRequest)
        }
        
        scheduler.scheduleAt(30) {
            feature.accept(.changeInput(.identifier, nil))
            feature.accept(.changeInput(.password, "3"))
            feature.accept(.startRequest)
        }
        
        scheduler.scheduleAt(40) {
            validator.validPassword = "3"
            feature.accept(.startRequest)
        }
        
        scheduler.scheduleAt(50) {
            feature.accept(.changeInput(.password, "3"))
            feature.accept(.startRequest)
        }
        
        scheduler.scheduleAt(60) {
            feature.accept(.changeSignInOrSignUp(.signUp))
            feature.accept(.startRequest)
        }
        
        scheduler.scheduleAt(70) {
            feature.accept(.toggleAcceptPolicy)
            feature.accept(.startRequest)
        }
        
        scheduler.scheduleAt(100) {
            XCTAssert(stateResult.lastElement(at: 10).identifier.validationError == "error")
            XCTAssert(stateResult.lastElement(at: 10).password.validationState == .valid)
            XCTAssert(stateResult.haveElement(at: 10, where: { $0.requestInProgress == true }))
            XCTAssert(stateResult.lastElement(at: 10).requestInProgress == false)
            XCTAssert(newsResult.lastElement(at: 10) == .requestFailed(.identifierValidation))
            
            XCTAssert(stateResult.lastElement(at: 20).identifier.validationError == "error")
            XCTAssert(stateResult.lastElement(at: 20).password.validationState == .valid)
            XCTAssert(newsResult.lastElement(at: 20) == .requestFailed(.identifierValidation))
            
            XCTAssert(stateResult.lastElement(at: 30).identifier.validationState == .valid)
            XCTAssert(stateResult.lastElement(at: 30).password.validationError == "error")
            XCTAssert(newsResult.lastElement(at: 30) == .requestFailed(.passwordValidation))
            
            XCTAssert(stateResult.lastElement(at: 40).identifier.validationState == .valid)
            XCTAssert(stateResult.lastElement(at: 40).password.validationError == "error")
            XCTAssert(newsResult.lastElement(at: 40) == .requestFailed(.passwordValidation))
            
            XCTAssert(stateResult.lastElement(at: 50).identifier.validationState == .valid)
            XCTAssert(stateResult.lastElement(at: 50).password.validationState == .valid)
            XCTAssert(newsResult.lastElement(at: 50) == .requestFailed(.fromBackend("server")))
            
            XCTAssert(stateResult.lastElement(at: 60).identifier.validationState == .valid)
            XCTAssert(stateResult.lastElement(at: 60).password.validationState == .valid)
            XCTAssert(newsResult.lastElement(at: 60) == .requestFailed(.shouldAccepPolicy))
            
            XCTAssert(stateResult.haveElement(at: 70, where: { $0.requestInProgress == true }))
            XCTAssert(stateResult.lastElement(at: 70).requestInProgress == false)
            XCTAssert(newsResult.lastElement(at: 70) == .requestFailed(.fromBackend("server")))

            subscription1.dispose()
            subscription2.dispose()
        }
        
        scheduler.start()
    }
    
    func test_AuthFeature_Request() throws {
        let scheduler = TestScheduler(initialClock: 0, simulateProcessingDelay: true)
        RxHolder.mainScheduler = scheduler

        let sessionFeatureConsumer = FeatureMock<SessionFeature.Wish, Void>(wish: { _ in })
        var signUpFail = true
        
        let network = NetworkMock { api in
            let user = UserDTO(id: 10, avatar: nil, username: nil, online: nil, followersCount: nil, followedByMe: nil, followers: nil, additionalIndo: nil, posts: nil, likedPosts: nil)
            let data = try! JSONEncoder().encode(user)
            let response = Response(statusCode: 200, data: data)
            switch api {
            case let .signIn(identifier, password):
                guard identifier == "1", password == "2" else {
                    fallthrough
                }
                return scheduler.createColdObservable(delay: 1, just: response).asSingle()
            case let .signUp(identifier, password):
                guard !signUpFail else { fallthrough }
                guard identifier == "1", password == "2" else {
                    fallthrough
                }
                return scheduler.createColdObservable(delay: 3, just: response).asSingle()
            default:
                return .error(ApiError(reason: .internalLogicError, serverError: "wrong credentials"))
            }
        }
        
        
        let validator = AuthCredentialsValidatorMock(scheduler: scheduler, failed: false)
        let feature = AuthFeature(sessionFeatureConsumer: sessionFeatureConsumer, network: network, authCredentialsValidator: validator)

        let disposeBag = DisposeBag()
        let newsResult = scheduler.createObserver(AuthFeature.News.self)
        
        scheduler.scheduleAt(0) {
            feature.news.subscribe(newsResult).disposed(by: disposeBag)
        }
        scheduler.scheduleAt(10) {
            feature.accept(.startRequest)
        }
        scheduler.scheduleAt(20) {
            feature.accept(.changeInput(.identifier, "1"))
            feature.accept(.changeInput(.password, "2"))
            feature.accept(.startRequest)
        }
        
        scheduler.scheduleAt(30) {
            feature.accept(.changeSignInOrSignUp(.signUp))
            feature.accept(.toggleAcceptPolicy)
            feature.accept(.startRequest)
        }
        
        scheduler.scheduleAt(40) {
            signUpFail = false
            feature.accept(.startRequest)
        }
        
        scheduler.scheduleAt(100) {
            print(newsResult.events.map({ "\($0)" }).joined(separator: "\n"))
            XCTAssert(newsResult.lastElement(at: 10) == .requestFailed(.fromBackend("wrong credentials")))
            
            XCTAssert(newsResult.lastElement(at: 21) == .loggedIn(id: 10))
            
            XCTAssert(newsResult.lastElement(at: 30) == .requestFailed(.fromBackend("wrong credentials")))

            XCTAssert(newsResult.lastElement(at: 43) == .registered(id: 10))
            _ = disposeBag //to capture
        }
        
        scheduler.start()
    }
}

extension AuthScreenState.Text.ValidationState: Equatable {
    public static func == (lhs: AuthScreenState.Text.ValidationState, rhs: AuthScreenState.Text.ValidationState) -> Bool {
        switch (lhs, rhs) {
        case (.waiting, .waiting), (.valid, .valid), (.invalid, .invalid):
            return true
        case let (.validationInProgress(uid1), .validationInProgress(uid2)):
            return uid1 == uid2
        default:
            return false
        }
    }
}

extension AuthFeature.News: Equatable {
    public static func == (lhs: AuthFeature.News, rhs: AuthFeature.News) -> Bool {
        switch (lhs, rhs) {
        case (.loggedIn, .loggedIn), (.registered, .registered):
            return true
        case let (.requestFailed(err1), .requestFailed(err2)):
            switch (err1, err2) {
            case (.identifierValidation, .identifierValidation), (.passwordValidation, .passwordValidation), (.shouldAccepPolicy, .shouldAccepPolicy):
                return true
            case let (.fromBackend(msg1), .fromBackend(msg2)):
                return msg1 == msg2
            default:
                return false
            }
        default:
            return false
        }
    }
}

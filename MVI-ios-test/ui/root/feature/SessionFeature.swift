//
//  SessionFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 20.07.2021.
//

import Foundation
import Moya

final class SessionFeature: BaseFeature<SessionFeature.Wish, SessionState, SessionFeature.News, SessionFeature.InnerPart> {
    enum Wish {
        case authSuccessed
        case logout
    }
    
    enum News {
        case loadProfileError(Error)
    }
    
    init(session: Session, network: Network) {
        super.init(initialState: .checking, innerPart: InnerPart(session: session, network: network))
    }

    struct InnerPart: InnerFeatureProtocol {
        private let session: Session
        private let network: Network
        fileprivate init(session: Session, network: Network) {
            self.session = session
            self.network = network
        }
        
        typealias Wish = SessionFeature.Wish
        typealias News = SessionFeature.News
        typealias State = SessionState
        
        enum Action {
            case checkSession
            case loadProfile
            case signedIn
            case logout
        }
        
        struct Effect {
            let changeStateTo: SessionState
            let error: Error?
            
            internal init(_ state: SessionState, error: Error? = nil) {
                self.changeStateTo = state
                self.error = error
            }
        }
        
        func bootstrapper() -> Observable<Action> {
            Observable.just(.checkSession)
        }
        
        func action(from wish: Wish) -> Action {
            switch wish {
            case .authSuccessed:
                return .signedIn
            case .logout:
                return .logout
            }
        }
        
        func actor<Holder>(from action: Action, stateHolder: Holder) -> Observable<Effect> where Holder : StateHolder, State == Holder.State {
            switch action {
            case .checkSession:
                return checkSession()
                    .map { _ in Effect(.loadingProfile) }
                    .catchError { _ in .just(Effect(.waitingAuth)) }
                    .asObservable()
            case .loadProfile:
                return getProfile()
                    .map { _ in Effect(.signedIn) }
                    .catchError { Single.just(Effect(.waitingAuth, error: $0)) }
                    .asObservable()
            case .signedIn:
                return .just(Effect(.signedIn))
            case .logout:
                return logout()
                    .map { _ in Effect(.waitingAuth) }
                    .asObservable()
            }
        }
        
        func news(from action: Action, effect: Effect, state: State) -> News? {
            if action == .loadProfile, let error = effect.error {
                return .loadProfileError(error)
            }
            return nil
        }
        
        func postProcessor(oldState: State, action: Action, effect: Effect, state: State) -> Action? {
            if effect.changeStateTo == .loadingProfile {
                return .loadProfile
            }
            return nil
        }
        
        func reduce(with effect: Effect, state: inout State) {
            state = effect.changeStateTo
        }
        
        enum CheckSessionError: Error {
            case noCookies, backend
        }
        
        private func checkSession() -> Single<Void> {
            guard session.hasCookies == true else { return .error(CheckSessionError.noCookies) }
            
            return network
                .request(.sessionCheck)
                .mapJSON()
                .flatMap {
                    let dict = $0 as? [String: Any]
                    return dict?["success"] as? Bool == true ? .just(()) : .error(CheckSessionError.backend)
                }
        }
        
        private func getProfile() -> Single<Int> {
            network
                .request(.getProfile)
                .map(to: ProfileDTO.self)
                .map { $0.id }
        }
        
        private func logout() -> Single<Response> {
            network
                .request(.logout)
        }
    }
}

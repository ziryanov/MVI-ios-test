//
//  AuthFeature.swift
//  MVI-ios-test
//
//  Created by ziryanov on 29.07.2021.
//

import Foundation

final class AuthFeature: BaseFeature<AuthFeature.Wish, AuthScreenState, AuthFeature.News, AuthFeature.InnerPart> {
    
    enum Wish {
        case startInput(AuthScreenState.TextType)
        case changeInput(AuthScreenState.TextType, String?)
        case finishInput
        
        case toggleAcceptPolicy
        case changeSignInOrSignUp(AuthScreenState.SignInOrSignUp)
        
        case startRequest
    }
    
    enum News {
        case loggedIn(Int)
        case registered(Int)
        
        enum RequestError: Swift.Error {
            case identifierValidation
            case passwordValidation
            case shouldAccepPolicy
            case fromBackend(String)
        }
        case requestFailed(RequestError)
    }
    
    init(sessionFeature: SessionFeature, network: Network, authCredentialsValidator: AuthCredentialsValidator) {
        super.init(initialState: .init(), innerPart: InnerPart(network: network, authCredentialsValidator: authCredentialsValidator))
        
        news
            .subscribe(onNext: {
                switch $0 {
                case .loggedIn, .registered:
                    sessionFeature.accept(.authSuccessed)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    class InnerPart: FeatureInnerPart {
        private let network: Network
        private let authCredentialsValidator: AuthCredentialsValidator
        fileprivate init(network: Network, authCredentialsValidator: AuthCredentialsValidator) {
            self.network = network
            self.authCredentialsValidator = authCredentialsValidator
        }
        
        typealias Wish = AuthFeature.Wish
        typealias News = AuthFeature.News
        typealias State = AuthScreenState
       
        enum Action {
            case wish(Wish)
            case internalStartRequest
            case validate(AuthScreenState.TextType)
        }
        
        enum Effect {
            case applyWish(Wish)
            
            case startValidation(AuthScreenState.TextType, uuid: UUID)
            case completeValidation(AuthScreenState.TextType, error: AuthValidatorError?)
            
            case requestFinishedWithError(News.RequestError)
            case requestFinishedWithSuccess(Int)
        }
        
        func action(from wish: Wish) -> Action {
            .wish(wish)
        }

        func actor<Holder>(from action: Action, stateHolder: Holder) -> Observable<Effect> where Holder : StateHolder, State == Holder.State {
            let currentState = stateHolder.state
            switch action {
            case .wish(let wish):
                switch wish {
                case .startRequest:
                    return Maybe<Effect>
                        .just(.applyWish(wish), if: !stateHolder.state.requestInProgress)
                        .asObservable()
                default:
                    return .just(.applyWish(wish))
                }
            case .internalStartRequest:
                let validations = validateAllFields(in: currentState)
                    .asObservable()
                    .flatMap { errors -> Observable<Effect> in
                        if let requestError = errors.first?.requestError {
                            let effectsFromValidationErrors: [Effect] = errors.compactMap {
                                guard let textType = $0.textType, let validationError = $0.validationError else { return nil }
                                return Effect.completeValidation(textType, error: validationError)
                            }
                            return Observable
                                .from(effectsFromValidationErrors)
                                .concat(Observable.just(Effect.requestFinishedWithError(requestError)))
                                .concat(Observable.error(requestError))
                        } else {
                            return .empty()
                        }
                    }
                
                let request = createRequest(state: currentState)
                    .map { Effect.requestFinishedWithSuccess($0) }
                    .catchError {
                        let text = ($0 as? ApiError)?.serverError ?? "Something go wrong"
                        return Single.just(Effect.requestFinishedWithError(.fromBackend(text)))
                    }
                
                return Observable
                    .concat(validations)
                    .concat(request)
                
            case .validate(let textType):
                let uuid = UUID()
                let validation = self.validation(of: textType, in: currentState)
                    .flatMapMaybe { [weak self, weak stateHolder] validationError -> Maybe<Effect> in
                        guard let state = stateHolder?.state, case .validationInProgress(let oldUuid) = self?.text(textType, in: state).validationState, oldUuid == uuid else {
                            return .empty()
                        }
                        return .just(Effect.completeValidation(textType, error: validationError))
                    }
                return Observable
                    .just(.startValidation(textType, uuid: uuid))
                    .concat(validation)
            }
        }

        func reduce(with effect: Effect, state: inout State) {
            switch effect {
            case .applyWish(let wish):
                switch wish {
                case .startInput(let textType):
                    state.editingText = textType
                case .changeInput(let textType, let string):
                    changeText(in: &state, textType: textType) {
                        $0.value = string ?? ""
                        $0.validationState = .waiting
                    }
                case .finishInput:
                    state.editingText = nil
                case .toggleAcceptPolicy:
                    state.acceptPolicy = !state.acceptPolicy
                case .changeSignInOrSignUp(let new):
                    state.signInOrSignUp = new
                case .startRequest:
                    state.requestInProgress = true
                }
            case .startValidation(let textType, let uuid):
                changeText(in: &state, textType: textType) {
                    $0.validationState = .validationInProgress(uuid)
                }
            case .completeValidation(let textType, let error):
                changeText(in: &state, textType: textType) {
                    if let error = error {
                        $0.validationState = .invalid(error)
                    } else {
                        $0.validationState = .valid
                    }
                }
            case .requestFinishedWithError, .requestFinishedWithSuccess:
                state.requestInProgress = false
            }
        }
        
        func postProcessor(oldState: State, action: Action, effect: Effect, state: State) -> Action? {
            if let oldEditingState = oldState.editingText, oldEditingState != state.editingText {
                return .validate(oldEditingState)
            }
            if case let .applyWish(wish) = effect, case let .changeInput(textType, _) = wish, textType != state.editingText { //for debug "fill all"
                return .validate(textType)
            }
            if oldState.signInOrSignUp != state.signInOrSignUp {
                switch state.identifier.validationState {
                case .waiting:
                    break
                default:
                    return .validate(.identifier)
                }
            }
            if oldState.requestInProgress != state.requestInProgress, state.requestInProgress {
                return .internalStartRequest
            }
            return nil
        }
        
        func news(from action: Action, effect: Effect, state: State) -> News? {
            if case .requestFinishedWithError(let error) = effect {
                return .requestFailed(error)
            }
            if case .requestFinishedWithSuccess(let id) = effect {
                switch state.signInOrSignUp {
                case .signIn:
                    return .loggedIn(id)
                case .signUp:
                    return .registered(id)
                }
            }
            return nil
        }
        
        //---
        
        private func text(_ textType: AuthScreenState.TextType, in state: AuthScreenState) -> AuthScreenState.Text {
            switch textType {
            case .identifier:
                return state.identifier
            case .password:
                return state.password
            }
        }
        
        private func changeText(in state: inout AuthScreenState, textType: AuthScreenState.TextType, block: (inout AuthScreenState.Text) -> Void) {
            switch textType {
            case .identifier:
                block(&state.identifier)
            case .password:
                block(&state.password)
            }
        }
        
        private func validation(of textType: AuthScreenState.TextType, in state: AuthScreenState) -> Single<AuthValidatorError?> {
            switch text(textType, in: state).validationState {
            case .valid:
                return .just(nil)
            case .invalid(let error):
                if let error = error as? AuthValidatorError {
                    return .just(error)
                }
            default:
                break
            }
            
            switch textType {
            case .identifier:
                return authCredentialsValidator.validateIdentifier(state.identifier.value, signInOrSignUp: state.signInOrSignUp)
            case .password:
                return authCredentialsValidator.validatePassword(state.password.value)
            }
        }
        
        struct ValidateAllFieldsResult {
            let textType: AuthScreenState.TextType?
            let validationError: AuthValidatorError?
            let requestError: News.RequestError
        }
        
        private func validateAllFields(in state: AuthScreenState) -> Single<[ValidateAllFieldsResult]> {
            let validateIdentifier = self.validation(of: .identifier, in: state)
                .map { error -> ValidateAllFieldsResult? in
                    guard error != nil else { return nil }
                    return ValidateAllFieldsResult(textType: .identifier, validationError: error, requestError: .identifierValidation)
                }
            let validatePassword = self.validation(of: .password, in: state)
                .map { error -> ValidateAllFieldsResult? in
                    guard error != nil else { return nil }
                    return ValidateAllFieldsResult(textType: .password, validationError: error, requestError: .passwordValidation)
                }
            let validateAcceptPolicy = Single<ValidateAllFieldsResult?>.create { observer in
                if state.signInOrSignUp == .signUp, state.acceptPolicy == false {
                    observer(.success(ValidateAllFieldsResult(textType: nil, validationError: nil, requestError: .shouldAccepPolicy)))
                } else {
                    observer(.success(nil))
                }
                return Disposables.create()
            }
            return Single
                .zip([ validateIdentifier, validatePassword, validateAcceptPolicy ])
                .map { errors in errors.compactMap({ $0 }) }
        }
        
        private func createRequest(state: AuthScreenState) -> Single<Int> {
            let api: API
            switch state.signInOrSignUp {
            case .signIn:
                api = .signIn(identifier: state.identifier.value, password: state.password.value)
            case .signUp:
                api = .signUp(identifier: state.identifier.value, password: state.password.value)
            }
            return network
                .request(api)
                .map(to: ProfileDTO.self)
                .map { $0.id }
        }
    }
}

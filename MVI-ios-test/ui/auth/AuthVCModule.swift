//
//  AuthVCModule.swift
//  ReduxVMSample
//
//  Created by ziryanov on 14.10.2020.
//

import Foundation
import DeclarativeTVC
import DITranquillity

enum AuthVCModule {

    typealias ViewController = AuthVC

    struct Props {
        let identifier: String
        let identifierError: String?
        
        let password: String
        let passwordError: String?
        
        let accept: Bool

        let currentSegment: AuthScreenState.SignInOrSignUp

        let buttonLoading: Bool
    }
    
    struct Actions {
        let changeSegment: CommandWith<AuthScreenState.SignInOrSignUp>
        let startInput: CommandWith<AuthScreenState.TextType>
        let endInput: Command
        let changeValue: CommandWith<(AuthScreenState.TextType, String?)>
        let togglePolicy: Command
        let startRequest: Command
    }

    final class Presenter: PresenterBase<ViewController, AuthFeature> {
        
        override func _createView() -> ViewController {
            return ViewController.controllerFromStoryboard()
        }
        
        override func _props(for state: State) -> Props {
            Props(identifier: state.identifier.value,
                  identifierError: state.identifier.validationError,
                  password: state.password.value,
                  passwordError: state.password.validationError,
                  accept: state.acceptPolicy,
                  currentSegment: state.signInOrSignUp,
                  buttonLoading: state.requestInProgress)
        }
        
        override func _actions(for state: State) -> Actions {
            Actions(changeSegment: .init { [unowned feature] in
                feature.accept(.changeSignInOrSignUp($0))
            },
            startInput: .init { [unowned feature] in
                feature.accept(.startInput($0))
            },
            endInput: .init { [unowned feature] in
                feature.accept(.finishInput)
            },
            changeValue: .init { [unowned feature] in
                feature.accept(.changeInput($0.0, $0.1))
            },
            togglePolicy: .init { [unowned feature] in
                feature.accept(.toggleAcceptPolicy)
            },
            startRequest: .init { [unowned feature] in
                feature.accept(.startRequest)
            })
        }
    }
    
    final class DI: DIPart {
        static func load(container: DIContainer) {
            container.register (AuthCredentialsValidator.init)
                .lifetime(.objectGraph)
            container.register (AuthFeature.init)
                .lifetime(.objectGraph)
        }
    }
}

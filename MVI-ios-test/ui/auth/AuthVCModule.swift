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

    class Presenter<View: PropsReceiver & ActionsReceiver & WishConsumer & PresenterHolder & AnyObject>: PresenterBase<View, AuthFeature>  where View.Wish == AuthFeature.News, View.Props == Props, View.Actions == Actions {
        
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
                feature.accept(wish: .changeSignInOrSignUp($0))
            },
            startInput: .init { [unowned feature] in
                feature.accept(wish: .startInput($0))
            },
            endInput: .init { [unowned feature] in
                feature.accept(wish: .finishInput)
            },
            changeValue: .init { [unowned feature] in
                feature.accept(wish: .changeInput($0.0, $0.1))
            },
            togglePolicy: .init { [unowned feature] in
                feature.accept(wish: .toggleAcceptPolicy)
            },
            startRequest: .init { [unowned feature] in
                feature.accept(wish: .startRequest)
            })
        }
    }
    
    final class DI: DIPart {
        static func load(container: DIContainer) {
            container.register (AuthCredentialsValidator.init)
                .as(AuthCredentialsValidatorType.self)
                .lifetime(.objectGraph)
            container.register { (n: NetworkType, acv: AuthCredentialsValidatorType) -> AuthFeature in
                let sessionFeature: SessionFeature = container.resolve()
                return AuthFeature.init(sessionFeatureWishConsumer: sessionFeature, network: n, authCredentialsValidator: acv)
            }
            .lifetime(.objectGraph)
        }
    }
}

//extension AuthVCModule.Presenter where View == AuthVC {
//    static func createAndReturnView(with feature: AuthFeature) -> UIViewController {
//        let vc = AuthVC.controllerFromStoryboard()
//        let presenter = self.init(feature: feature, view: vc)
//        return presenter.view
//    }
//}

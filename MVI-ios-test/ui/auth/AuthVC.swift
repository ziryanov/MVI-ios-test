//
//  AuthVC.swift
//  MVI-ios-test
//
//  Created by ziryanov on 03.08.2021.
//

import UIKit
import Dodo
import IHKeyboardAvoiding
import DTTextField
import LTHRadioButton
import RxCocoa
import LGButton

final class AuthVC: VC<AuthVCModule.Props, AuthVCModule.Actions>, Consumer {
    typealias Consumable = AuthFeature.News
    
    public class override var storyboardName: String {
        return "Auth"
    }
    
    @IBOutlet private var segment: UISegmentedControl!
    @IBOutlet private var identifier: DTTextField!
    @IBOutlet private var password: DTTextField!
    
    @IBOutlet private var bottomPanel: UIScrollView!
    @IBOutlet private var acceptPolicy: LTHRadioButton!
    @IBOutlet private var acceptPolicyButton: UIControl!
    
    @IBOutlet private var requestButton: LGButton!

    private let startOffset = CGPoint(x: -1, y: 0)
    override func viewDidLoad() {
        super.viewDidLoad()

        identifier.placeholder = "Identifier"
        password.placeholder = "Password"

        for (i, idx) in segmentIndexes.enumerated() {
            let name = segmentName(for: idx)
            segment.setTitle(name, forSegmentAt: i)
        }
        
        bottomPanel.contentOffset = startOffset
        
        requestButton.leftIconFontName = "fa"
        requestButton.leftIconString = "sign-in"

        KeyboardAvoiding.avoidingView = view.subviews.first

        view.dodo.topAnchor = view.safeAreaLayoutGuide.topAnchor
        view.dodo.bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        view.dodo.style.bar.hideAfterDelaySeconds = 3
        navigationController?.isNavigationBarHidden = true
        bottomPanel.canCancelContentTouches = false
    }

    func accept(_ t: Consumable) {
        switch t {
        case .requestFailed(let error):
            switch error {
            case .identifierValidation:
                identifier.miniShake()
            case .passwordValidation:
                password.miniShake()
            case .shouldAccepPolicy:
                acceptPolicy.topViewInStackView?.miniShake()
            case .fromBackend(let text):
                view.dodo.error(text)
            }
        default:
            break
        }
    }
    
    typealias MW = ModelWatcher<AuthVCModule.Props>
    
    @ModelWatcherBuilder<AuthVCModule.Props> var modelWatcher: MW {
        MW.Watch(\AuthVCModule.Props.identifier) { [unowned self] in
            self.identifier.text = $0
        }
        MW.Watch(\AuthVCModule.Props.identifierError) { [unowned self] in
            if let error = $0 {
                self.identifier.showError(message: error)
            } else {
                self.identifier.hideError()
            }
        }
        
        MW.Watch(\AuthVCModule.Props.password) { [unowned self] in
            self.password.text = $0
        }
        MW.Watch(\AuthVCModule.Props.passwordError) { [unowned self] in
            if let error = $0 {
                self.password.showError(message: error)
            } else {
                self.password.hideError()
            }
        }
        
        MW.Watch(\AuthVCModule.Props.currentSegment) { [unowned self] in
            if let i = self.segmentIndexes.firstIndex(of: $0) {
                self.segment.selectedSegmentIndex = i
            }

            self.bottomPanel.setContentOffset(CGPoint(x: CGFloat(self.segment.selectedSegmentIndex) * self.bottomPanel.frame.width, y: 0), animated: self.bottomPanel.contentOffset != self.startOffset)
            
            self.requestButton.titleString = self.segmentName(for: $0)
            self.requestButton.loadingString = self.buttonLoadingName(for: $0)
        }
        
        MW.Watch(\AuthVCModule.Props.accept) { [unowned self] in
            if $0 {
                acceptPolicy.select(animated: true)
            } else {
                acceptPolicy.deselect(animated: true)
            }
        }
        
        MW.Watch(\AuthVCModule.Props.buttonLoading) { [unowned self] in
            self.requestButton.isLoading = $0
        }
    }

    override func render(props: AuthVCModule.Props) {
        modelWatcher.apply(props)
    }

    override func apply(actions: AuthVCModule.Actions) {
        segment.rx.controlEvent(.valueChanged)
            .bind { [segmentIndexes, segment, action = actions.changeSegment] in
                guard let index = segmentIndexes[safe: segment?.selectedSegmentIndex] else { return }
                action.perform(with: index)
            }
            .disposed(by: rx.disposeBag(tag: "segment"))

        identifier.rx.controlEvent(.editingDidBegin)
            .bind { [action = actions.startInput] _ in
                action.perform(with: .identifier)
            }
            .disposed(by: rx.disposeBag(tag: "identifierStart"))
        identifier.rx.controlEvent(.editingDidEnd)
            .bind { [action = actions.endInput] _ in
                action.perform()
            }
            .disposed(by: rx.disposeBag(tag: "identifierEnd"))
        identifier.rx.controlEvent(.editingChanged)
            .bind { [action = actions.changeValue] in
                action.perform(with: (.identifier, self.identifier.text))
            }
            .disposed(by: rx.disposeBag(tag: "identifierChanged"))

        password.rx.controlEvent(.editingDidBegin)
            .bind { [action = actions.startInput] _ in
                action.perform(with: .password)
            }
            .disposed(by: rx.disposeBag(tag: "passwordStart"))
        password.rx.controlEvent(.editingDidEnd)
            .bind { [action = actions.endInput] _ in
                action.perform()
            }
            .disposed(by: rx.disposeBag(tag: "passwordEnd"))
        password.rx.controlEvent(.editingChanged)
            .bind { [action = actions.changeValue] in
                action.perform(with: (.password, self.password.text))
            }
            .disposed(by: rx.disposeBag(tag: "passwordChanged"))

        acceptPolicyButton.rx.controlEvent(.touchDown)
            .bind { [action = actions.togglePolicy] in
                action.perform()
            }
            .disposed(by: rx.disposeBag(tag: "acceptPolicy"))

        requestButton.rx.controlEvent(.touchUpInside)
            .bind { [unowned view, action = actions.startRequest] _ in
                view?.dodo.hide()
                action.perform()
            }
            .disposed(by: rx.disposeBag(tag: "requestButton"))
        
        debugActions = actions
    }

    private var debugActions: AuthVCModule.Actions!
    @IBAction private func degubFill() {
        debugActions.changeValue.perform(with: (.identifier, "qwe@ewq.com"))
        debugActions.changeValue.perform(with: (.password, "12345678"))
        debugActions.togglePolicy.perform()
    }
    
    private var segmentIndexes: [AuthScreenState.SignInOrSignUp] {
        return [.signIn, .signUp]
    }

    private func segmentName(for idx: AuthScreenState.SignInOrSignUp) -> String {
        switch idx {
        case .signIn:
            return "Sign in"
        case .signUp:
            return "Sign up"
        }
    }

    private func buttonLoadingName(for idx: AuthScreenState.SignInOrSignUp) -> String {
        switch idx {
        case .signIn:
            return "Signing in..."
        case .signUp:
            return "Signing up..."
        }
    }
}

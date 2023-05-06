//
//  LoginViewController.swift
//  PresentationInterface
//
//  Created by 박천송 on 2023/04/27.
//

import Foundation

import AuthenticationServices
import UIKit

import RxCocoa
import RxSwift

// MARK: - LoginResponse

struct LoginResponse: Codable {
  let accessToken: String
}

// MARK: - LoginViewController

final class LoginViewController: UIViewController {
  private let viewModel: LoginViewModel?
  private let disposeBag = DisposeBag()

  private let contentView = LoginView()

  init(viewModel: LoginViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white
    bind()
  }

  override func loadView() {
    super.loadView()

    view = contentView
  }

  private func bind() {
    bindButtons()
  }

  private func bindButtons() {
    contentView.appleButton.rx.controlEvent(.touchUpInside)
      .subscribe(with: self) { viewcontroller, _ in
        viewcontroller.viewModel?.appleLoginButtonTapped()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: ASAuthorizationControllerDelegate

extension LoginViewController: ASAuthorizationControllerDelegate {
  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    switch authorization.credential {
    case let appleIdCredential as ASAuthorizationAppleIDCredential:
      viewModel?.validateAppleIdCredential(appleIdCredential)
    case let passwordCredential as ASPasswordCredential:
      viewModel?.handlePasswordCredential(passwordCredential)
    default:
      break
    }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {}
}

// MARK: ASAuthorizationControllerPresentationContextProviding

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return view.window!
  }
}

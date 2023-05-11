//
//  LoginView.swift
//  Presentation
//
//  Created by 박천송 on 2023/04/30.
//

import AuthenticationServices
import Foundation
import UIKit

import FlexLayout
import PinLayout
import SnapKit
import Then

class LoginView: UIView {
  private let flexContainer = UIView()

  let googleButton = UIButton().then {
    $0.setTitle("Google", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .black
  }

  let appleButton = ASAuthorizationAppleIDButton()

  // MARK: Initializing

  override init(frame: CGRect) {
    super.init(frame: frame)

    defineLayout()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  // MARK: Layout

  private func defineLayout() {
    addSubview(flexContainer)
    [googleButton, appleButton].forEach { flexContainer.addSubview($0) }

    flexContainer.snp.makeConstraints {
      $0.edges.equalTo(safeAreaLayoutGuide)
    }

    appleButton.snp.makeConstraints {
      $0.left.right.equalToSuperview().inset(20)
      $0.bottom.equalToSuperview().inset(20.0)
      $0.height.equalTo(50.0)
    }

    googleButton.snp.makeConstraints {
      $0.left.right.equalToSuperview().inset(20)
      $0.bottom.equalTo(appleButton.snp.top).offset(-20.0)
      $0.height.equalTo(50.0)
    }
  }
}

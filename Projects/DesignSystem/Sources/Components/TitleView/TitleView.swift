//
//  File.swift
//  DesignSystem
//
//  Created by 박천송 on 2023/07/04.
//

import Foundation
import UIKit

import SnapKit
import Then

public final class TitleView: UIView {

  public var title: String? {
    didSet {
      titleLabel.attributedText = title?.styled(font: .defaultSemiBold, color: .gray900)
    }
  }

  // MARK: UI

  private let container = UIView()

  private let titleLabel = UILabel()

  public let closeButton = UIButton().then {
    $0.setImage(
      DesignSystemAsset.iconCloseOutline.image.withTintColor(.gray900),
      for: .normal
    )
  }

  public var onCloseAction: (() -> Void)?

  private let divider = UIView().then {
    $0.backgroundColor = .border1
  }

  // MARK: Initialize

  public override init(frame: CGRect) {
    super.init(frame: frame)

    defineLayout()

    configureTapAction()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }


  // MARK: Configuring

  private func configureTapAction() {
    closeButton.addAction(UIAction(handler: { [weak self] _ in
      self?.onCloseAction?()
    }), for: .touchUpInside)
  }


  // MARK: Layout

  private func defineLayout() {
    addSubview(container)

    [titleLabel, closeButton, divider].forEach { container.addSubview($0) }

    container.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalTo(60.0)
    }

    titleLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }

    closeButton.snp.makeConstraints {
      $0.right.equalToSuperview().inset(20.0)
      $0.centerY.equalToSuperview()
      $0.size.equalTo(24.0)
    }

    divider.snp.makeConstraints {
      $0.left.right.bottom.equalToSuperview()
      $0.height.equalTo(1.0)
    }
  }
}

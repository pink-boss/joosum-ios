//
//  PrimaryTabCell.swift
//  DesignSystem
//
//  Created by 박천송 on 2023/06/12.
//

import Foundation
import UIKit

class PrimaryTabCell: UICollectionViewCell {

  static let identifier = "PrimaryTabCell"

  // MARK: UI

  private let container = UIView()

  private let titleLabel = UILabel().then {
    $0.font = .subTitleRegular
    $0.textColor = .gray600
    $0.textAlignment = .center
  }

  private let underBar = UIView().then {
    $0.backgroundColor = .primary500
    $0.isHidden = true
  }


  // MARK: Properties

  override var isSelected: Bool {
    didSet {
      guard isSelected != oldValue else { return }
      configure(isSelected: isSelected)
    }
  }

  // MARK: Initialize

  override init(frame: CGRect) {
    super.init(frame: frame)

    defineLayout()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }


  // MARK: Configuring

  func configure(title: String) {
    titleLabel.attributedText = title.styled(font: .subTitleRegular, color: .gray600)
    titleLabel.textAlignment = .center
  }

  func configure(isSelected: Bool) {
    underBar.backgroundColor = .primary500

    if isSelected {
      underBar.isHidden = false
      titleLabel.attributedText = titleLabel.text?.styled(font: .subTitleBold, color: .primary500)
      titleLabel.textAlignment = .center
    } else {
      underBar.isHidden = true
      titleLabel.attributedText = titleLabel.text?.styled(font: .subTitleRegular, color: .gray600)
      titleLabel.textAlignment = .center
    }
  }


  // MARK: Layout

  private func defineLayout() {
    contentView.addSubview(container)
    [titleLabel, underBar].forEach { container.addSubview($0) }

    container.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalTo(40.0)
    }

    titleLabel.snp.makeConstraints {
      $0.left.right.equalToSuperview()
      $0.top.equalToSuperview().inset(4.0)
      $0.width.greaterThanOrEqualTo(68.0)
    }

    underBar.snp.makeConstraints {
      $0.left.right.equalToSuperview()
      $0.bottom.equalToSuperview().inset(4.0)
      $0.height.equalTo(2.0)
    }
  }
}

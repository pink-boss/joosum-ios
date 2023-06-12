import UIKit

import FlexLayout
import PinLayout
import RxCocoa
import RxSwift
import SnapKit
import Then

import DesignSystem

final class HomeView: UIView {
  // TODO: 테스트 버튼 (제거 예정)
  let testButton = UIButton().then {
    $0.setTitle("링크북 만들기", for: .normal)
    $0.setTitleColor(.label, for: .normal)
  }

  // MARK: Initializing

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = .gray300
    addSubview(testButton)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    testButton.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}

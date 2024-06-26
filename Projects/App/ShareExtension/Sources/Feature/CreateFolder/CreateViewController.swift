//
//  CreateViewController.swift
//  ShareExtension
//
//  Created by 박천송 on 3/14/24.
//  Copyright © 2024 PinkBoss Inc. All rights reserved.
//

import UIKit

import FirebaseAnalytics
import ReactorKit
import RxSwift

import DesignSystem
import Domain
import PBAnalyticsInterface
import PresentationInterface

public protocol CreateFolderDelegate: AnyObject {
  func createFolderSucceed(folder: Folder)
}

final class CreateFolderViewController: UIViewController, StoryboardView {

  // MARK: UI

  private let contentView = CreateFolderView()

  // MARK: Properties

  var disposeBag = DisposeBag()

  private let analytics: PBAnalytics = PBAnalyticsImpl(
    firebaseAnalytics: FirebaseAnalytics.Analytics.self
  )

  weak var delegate: CreateFolderDelegate?

  // MARK: Initializing

  init(
    reactor: CreateFolderViewReactor
  ) {
    defer { self.reactor = reactor }
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Life Cycle

  override func loadView() {
    super.loadView()

    view = contentView

    contentView.linkBookTabView.colorView.delegate = self
    contentView.linkBookTabView.illustView.delegate = self
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    reactor?.action.onNext(.viewDidLoad)

    contentView.linkBookTabView.folderView.inputField.addTarget(
      self,
      action: #selector(textDidChange),
      for: .editingChanged
    )
  }

  // MARK: Binding

  func bind(reactor: CreateFolderViewReactor) {
    bindButtons(with: reactor)
    bindContent(with: reactor)
    bindTextField(with: reactor)
    bindRoute(with: reactor)
  }

  private func bindButtons(with reactor: CreateFolderViewReactor) {
    contentView.titleView.closeButton.rx.controlEvent(.touchUpInside)
      .subscribe(with: self) { `self`, _ in
        self.analytics.log(type: ShareAddFolderEvent.click(component: .close))

        self.dismiss(animated: true)
      }
      .disposed(by: disposeBag)

    reactor.state.map(\.isMakeButtonEnabled)
      .distinctUntilChanged()
      .asObservable()
      .bind(to: contentView.linkBookTabView.makeButton.rx.isEnabled)
      .disposed(by: disposeBag)

    contentView.linkBookTabView.makeButton.rx.controlEvent(.touchUpInside)
      .subscribe(with: self) { `self`, _ in

        self.analytics.log(type: ShareAddFolderEvent.click(component: .saveFolder))

        reactor.action.onNext(.makeButtonTapped)
      }
      .disposed(by: disposeBag)
  }

  private func bindContent(with reactor: CreateFolderViewReactor) {
    reactor.state.map(\.backgroundColors)
      .distinctUntilChanged()
      .asObservable()
      .subscribe(with: self) { `self`, colors in
        self.contentView.linkBookTabView.colorView.configureBackground(
          colors: colors,
          selectedColor: reactor.currentState.viewModel.backgroundColor
        )
      }
      .disposed(by: disposeBag)

    reactor.state.map(\.titleColors)
      .distinctUntilChanged()
      .asObservable()
      .subscribe(with: self) { `self`, colors in
        self.contentView.linkBookTabView.colorView.configureTitleColor(
          colors: colors,
          selectedColor: reactor.currentState.viewModel.titleColor
        )
      }
      .disposed(by: disposeBag)

    reactor.state.compactMap(\.folder)
      .distinctUntilChanged()
      .asObservable()
      .subscribe(with :self) { `self`, folder in
        self.contentView.linkBookTabView.folderView.inputField.text = folder.title
        self.contentView.titleView.title = "폴더 수정"
        self.contentView.linkBookTabView.makeButton.text = "변경하기"
      }
      .disposed(by: disposeBag)

    reactor.state.map(\.viewModel)
      .distinctUntilChanged()
      .asObservable()
      .subscribe(with: self) { `self`, viewModel in
        if let illust = viewModel.illuste,
           let index = self.extractNumber(from: illust) {
          self.contentView.linkBookTabView.illustView.illustGrid.selectItem(
            at: IndexPath(item: index, section: 0),
            animated: true,
            scrollPosition: .centeredVertically
          )
        } else {
          self.contentView.linkBookTabView.illustView.illustGrid.selectItem(
            at: IndexPath(item: 0, section: 0),
            animated: true,
            scrollPosition: .centeredVertically
          )
        }

        self.contentView.previewView.configure(with: viewModel)
      }
      .disposed(by: disposeBag)

    contentView.linkBookTabView.tabView.selectedTab
      .subscribe(with: self) { `self`, tab in
        switch tab {
        case "폴더명":
          self.analytics.log(type: ShareAddFolderEvent.click(component: .folderTitleTab))
          self.contentView.linkBookTabView.showFolderView()
        case "색상":
          self.analytics.log(type: ShareAddFolderEvent.click(component: .folderColorTab))
          self.contentView.linkBookTabView.showColorView()
        case "일러스트":
          self.analytics.log(type: ShareAddFolderEvent.click(component: .folderIllustTab))
          self.contentView.linkBookTabView.showIllustView()
        default:
          self.contentView.linkBookTabView.showFolderView()
        }
      }
      .disposed(by: disposeBag)

    reactor.state.map(\.createFolderValidationResult)
      .distinctUntilChanged()
      .subscribe(with: self) { `self`, result in
        self.contentView.linkBookTabView.makeButton.isEnabled = result == .valid
        switch result {
        case .valid:
          self.contentView.linkBookTabView.folderView.inputField.do {
            $0.errorDescription = nil
            $0.hideError()
          }
        case .folderNameDuplication:
          self.contentView.linkBookTabView.folderView.inputField.do {
            $0.errorDescription = "같은 이름의 폴더가 존재합니다."
            $0.showError()
          }
        }
      }
      .disposed(by: disposeBag)
  }

  private func bindTextField(with reactor: CreateFolderViewReactor) {
    contentView.linkBookTabView.folderView.inputField.rx.text
      .skip(1)
      .map { Reactor.Action.updateTitle($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    contentView.linkBookTabView.folderView.inputField.rx.editingDidBegin
      .subscribe(with: self) { `self`, _ in
        self.analytics.log(type: ShareAddFolderEvent.click(component: .folderTitleInput))
      }
      .disposed(by: disposeBag)
  }

  private func bindRoute(with reactor: CreateFolderViewReactor) {
    reactor.state.compactMap(\.isSucceed)
      .distinctUntilChanged()
      .subscribe(with: self) { `self`, folder in
        self.dismiss(animated: true) {
          self.delegate?.createFolderSucceed(folder: folder)
        }
      }
      .disposed(by: disposeBag)
  }

  func extractNumber(from string: String) -> Int? {
    let pattern = "illust(\\d+)"

    do {
      let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
      let range = NSRange(string.startIndex..<string.endIndex, in: string)

      if let match = regex.firstMatch(in: string, options: [], range: range) {
        if let range = Range(match.range(at: 1), in: string) {
          let numberString = string[range]
          return Int(numberString)
        }
      }
    } catch {
      print("Error creating regex: \(error)")
    }

    return nil
  }

  @objc
  private func textDidChange(_ textField: UITextField) {
    if let text = textField.text {
      // 초과되는 텍스트 제거
      if text.count > 15 {
        DispatchQueue.main.async {
          textField.text = String(text.prefix(15))
        }
      }
    }
  }
}


// MARK: - CreateFolderColorViewDelegate

extension CreateFolderViewController: CreateFolderColorViewDelegate {
  func backgroundColorDidTap(at row: Int) {
    analytics.log(type: ShareAddFolderEvent.click(component: .folderColorButton))
    reactor?.action.onNext(.updateBackgroundColor(row))
  }

  func titleColorDidTap(at row: Int) {
    reactor?.action.onNext(.updateTitleColor(row))
  }
}


// MARK: - CreateFolderIllustViewDelegate

extension CreateFolderViewController: CreateFolderIllustViewDelegate {
  func illustView(_ illustView: CreateFolderIllustView, didSelectItemAt indexPath: IndexPath) {
    analytics.log(type: ShareAddFolderEvent.click(component: .folderIllustButton))
    reactor?.action.onNext(.updateIllust(indexPath.row))
  }
}




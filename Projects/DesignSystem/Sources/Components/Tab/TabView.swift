//
//  TabView.swift
//  DesignSystem
//
//  Created by 박천송 on 2023/06/12.
//

import Foundation
import UIKit

import RxRelay
import RxSwift
import SnapKit
import Then

enum TabSection: Hashable {
  case normal
}

public struct Tab: Hashable {
  public let title: String
  public let id: UUID

  public init(title: String, id: UUID) {
    self.title = title
    self.id = id
  }
}

public protocol TabViewDelegate: AnyObject {
  func tabView(_ tabView: TabView, didSelectedTab: String)
}

public final class TabView: UIView {

  // MARK: UI

  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: collectionViewLayout()
  ).then {
    $0.backgroundColor = .clear
    $0.showsHorizontalScrollIndicator = false
    $0.register(TabCell.self, forCellWithReuseIdentifier: TabCell.identifier)
    $0.delegate = self
    $0.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
  }


  // MARK: Properties

  private var tabs: [String] = []

  private lazy var diffableDataSource = self.collectionViewDataSource()

  public weak var delegate: TabViewDelegate?
  public var selectedTab: PublishRelay<String> = .init()


  // MARK: Initialize

  public convenience init(tabs: [String]) {
    self.init(frame: .zero)
    applyTabs(by: tabs)
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)

    defineLayout()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }


  // MARK: CollectionView

  public func applyTabs(by tabs: [String]) {
    self.tabs = tabs
    var snapshot = NSDiffableDataSourceSnapshot<TabSection, Tab>()

    snapshot.appendSections([.normal])
    snapshot.appendItems(tabs.map { Tab(title: $0, id: UUID()) }, toSection: .normal)

    diffableDataSource.apply(snapshot)

    if !tabs.isEmpty {
      collectionView.selectItem(
        at: IndexPath(item: 0, section: 0),
        animated: true,
        scrollPosition: .centeredHorizontally
      )
      delegate?.tabView(self, didSelectedTab: tabs.first!)
      selectedTab.accept(tabs.first!)
    }
  }

  public func selectItem(at row: Int) {
    DispatchQueue.main.async {
      self.collectionView.selectItem(
        at: IndexPath(item: row, section: 0),
        animated: false,
        scrollPosition: .centeredHorizontally
      )
    }
  }

  private func collectionViewLayout() -> UICollectionViewCompositionalLayout {
    let item = NSCollectionLayoutItem(
      layoutSize: NSCollectionLayoutSize(
        widthDimension: .estimated(68.0),
        heightDimension: .fractionalHeight(1.0)
      )
    )

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .estimated(68.0),
      heightDimension: .fractionalHeight(1.0)
    )

    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item]
    )

    let section = NSCollectionLayoutSection(group: group).then {
      $0.interGroupSpacing = 8.0
    }

    let configuration = UICollectionViewCompositionalLayoutConfiguration().then {
      $0.scrollDirection = .horizontal
    }

    return UICollectionViewCompositionalLayout(section: section).then {
      $0.configuration = configuration
    }
  }

  private func collectionViewDataSource() -> UICollectionViewDiffableDataSource<TabSection, Tab> {
    let dataSource = UICollectionViewDiffableDataSource<TabSection, Tab>(
      collectionView: collectionView
    ) { collectionView, indexPath, item in
      collectionView.dequeueReusableCell(
        withReuseIdentifier: TabCell.identifier, for: indexPath
      ).then {
        guard let cell = $0 as? TabCell else { return }
        cell.configureTitle(title: item.title)
      }
    }

    return dataSource
  }


  // MARK: Layout

  private func defineLayout() {
    addSubview(collectionView)

    collectionView.snp.makeConstraints {
      $0.height.equalTo(40.0)
      $0.left.right.equalToSuperview()
      $0.top.bottom.equalToSuperview().inset(8.0)
    }
  }
}


extension TabView: UICollectionViewDelegate {
  public func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    collectionView.scrollToItem(
      at: IndexPath(item: indexPath.row, section: 0),
      at: .centeredHorizontally,
      animated: true
    )

    delegate?.tabView(self, didSelectedTab: tabs[indexPath.row])
    selectedTab.accept(tabs[indexPath.row])
  }
}

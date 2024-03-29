//
//  HomeViewReactor.swift
//  Presentation
//
//  Created by 박천송 on 2023/07/05.
//

import Foundation

import ReactorKit
import RxSwift

import Domain
import PBAnalyticsInterface
import PBLog

final class HomeViewReactor: Reactor {

  enum Action {
    case viewDidLoad
    case viewWillAppear
    case createFolderSucceed
    case readLink(String)
    case refresh
  }

  enum Mutation {
    case setLinkList([Link])
    case setLinkViewModel(HomeLinkSectionViewModel)
    case setFolderList([Folder])
    case setFolderViewModel(HomeFolderSectionViewModel)
  }

  struct State {
    var linkList: [Link] = []
    var linkViewModel: HomeLinkSectionViewModel?

    var folderList: [Folder] = []
    var folderViewModel: HomeFolderSectionViewModel?
  }


  // MARK: Properties

  private let disposeBag = DisposeBag()

  let initialState: State

  private let analytics: PBAnalytics
  private let fetchLinkListUseCase: FetchAllLinksUseCase
  private let fetchFolderListUseCase: FetchFolderListUseCase
  private let getMeUseCase: GetMeUseCase
  private let getLinkListUseCase: GetAllLinksUseCase
  private let getFolderListUseCase: GetFolderListUseCase
  private let readLinkUseCase: ReadLinkUseCase


  // MARK: initializing

  init(
    analytics: PBAnalytics,
    fetchLinkListUseCase: FetchAllLinksUseCase,
    fetchFolderListUseCase: FetchFolderListUseCase,
    getMeUseCase: GetMeUseCase,
    getLinkListUseCase: GetAllLinksUseCase,
    getFolderListUseCase: GetFolderListUseCase,
    readLinkUseCase: ReadLinkUseCase
  ) {
    defer { _ = self.state }

    self.analytics = analytics
    self.fetchLinkListUseCase = fetchLinkListUseCase
    self.fetchFolderListUseCase = fetchFolderListUseCase
    self.getMeUseCase = getMeUseCase
    self.getLinkListUseCase = getLinkListUseCase
    self.getFolderListUseCase = getFolderListUseCase
    self.readLinkUseCase = readLinkUseCase

    self.initialState = State()
  }

  deinit {
    print("🗑️ deinit: \(type(of: self))")
  }


  // MARK: Mutate & Reduce

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .concat([
        fetchLinkList(),
        fetchFolderList(),
        getMe(),
      ])

    case .viewWillAppear:
      return .concat([
        getLinkList(),
        getFolderList(),
      ])

    case .createFolderSucceed:
      return fetchFolderList()

    case .refresh:
      return .concat([
        fetchLinkList(),
        fetchFolderList(),
      ])

    case .readLink(let id):
      return readLinkUseCase.execute(id: id)
        .asObservable()
        .do(onNext: { [weak self] in
          self?.action.onNext(.refresh)
        })
        .flatMap { _ in Observable<Mutation>.empty() }
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state

    switch mutation {
    case .setLinkList(let linkList):
      newState.linkList = linkList

    case .setLinkViewModel(let viewModel):
      newState.linkViewModel = viewModel

    case .setFolderList(let folderList):
      newState.folderList = folderList

    case .setFolderViewModel(let viewModel):
      newState.folderViewModel = viewModel
    }

    return newState
  }
}


extension HomeViewReactor {

  private func getFolderList() -> Observable<Mutation> {
    let folderList = getFolderListUseCase.execute()

    var viewModel = HomeFolderSectionViewModel(
      section: .normal,
      items: folderList.folders.map {
        .init(
          id: $0.id,
          coverColor: $0.backgroundColor,
          titleColor: $0.titleColor,
          title: $0.title,
          linkCount: $0.linkCount,
          illust: $0.illustration,
          isLast: false
        )
      }
    )
    viewModel.items.append(.init(
      id: "default",
      coverColor: "",
      titleColor: "",
      title: "",
      linkCount: 0,
      illust: nil,
      isLast: true
    ))

    return .concat([
      .just(Mutation.setFolderList(folderList.folders)),
      .just(Mutation.setFolderViewModel(viewModel)),
    ])
  }

  private func fetchFolderList() -> Observable<Mutation> {
    fetchFolderListUseCase.execute(sort: .createAt)
      .asObservable()
      .flatMap { folderList -> Observable<Mutation> in

        var viewModel = HomeFolderSectionViewModel(
          section: .normal,
          items: folderList.folders.map {
            .init(
              id: $0.id,
              coverColor: $0.backgroundColor,
              titleColor: $0.titleColor,
              title: $0.title,
              linkCount: $0.linkCount,
              illust: $0.illustration,
              isLast: false
            )
          }
        )
        viewModel.items.append(.init(
          id: "default",
          coverColor: "",
          titleColor: "",
          title: "",
          linkCount: 0,
          illust: nil,
          isLast: true
        ))

        return .concat([
          .just(Mutation.setFolderList(folderList.folders)),
          .just(Mutation.setFolderViewModel(viewModel)),
        ])
      }
  }

  private func getLinkList() -> Observable<Mutation> {
    var linkList = sortLinkList(linkList: getLinkListUseCase.execute())

    // 읽지않은 링크가 존재한다면
    if linkList.first(where: { $0.readCount == 0 }) != nil {
      linkList = linkList.filter { $0.readCount == 0 }
    }

    guard !linkList.isEmpty else {
      return .concat([
        .just(Mutation.setLinkList([])),
        .just(Mutation.setLinkViewModel(.init(section: .normal, items: []))),
      ])
    }

    let lastIndex = linkList.count < 5 ? linkList.endIndex : linkList.index(0, offsetBy: 5)
    let slicedLinkList = linkList[linkList.startIndex..<lastIndex]

    var viewModel = HomeLinkSectionViewModel(
      section: .normal,
      items: slicedLinkList.map {
        .init(
          id: $0.id,
          imageURL: $0.thumbnailURL,
          title: $0.title,
          tag: $0.tags.map { tag in
            ["#", tag, " "].joined()
          }.reduce("") { first, second in first + second },
          date: $0.createdAt,
          isMore: false
        )
      }
    )


    viewModel.items.append(.init(id: "", imageURL: nil, title: "", tag: "", date: "", isMore: true))

    return .concat([
      .just(Mutation.setLinkList([Link](slicedLinkList))),
      .just(Mutation.setLinkViewModel(viewModel)),
    ])
  }

  private func fetchLinkList() -> Observable<Mutation> {
    fetchLinkListUseCase.execute(sort: .createAt, order: .desc)
      .asObservable()
      .flatMap { list -> Observable<Mutation> in
        var linkList = list
        // 읽지않은 링크가 존재한다면
        if linkList.first(where: { $0.readCount == 0 }) != nil {
          linkList = linkList.filter { $0.readCount == 0 }
        }

        guard !linkList.isEmpty else {
          return .concat([
            .just(Mutation.setLinkList([])),
            .just(Mutation.setLinkViewModel(.init(section: .normal, items: []))),
          ])
        }

        let lastIndex = linkList.count < 5 ? linkList.endIndex : linkList.index(0, offsetBy: 5)
        let linkList2 = linkList[linkList.startIndex..<lastIndex]

        var viewModel = HomeLinkSectionViewModel(
          section: .normal,
          items: linkList2.map {
            .init(
              id: $0.id,
              imageURL: $0.thumbnailURL,
              title: $0.title,
              tag: $0.tags.map { tag in
                ["#", tag, " "].joined()
              }.reduce("") { first, second in first + second },
              date: $0.createdAt,
              isMore: false
            )
          }
        )


        viewModel.items.append(.init(id: "", imageURL: nil, title: "", tag: "", date: "", isMore: true))

        return .concat([
          .just(Mutation.setLinkList([Link](linkList))),
          .just(Mutation.setLinkViewModel(viewModel)),
        ])
      }
  }

  private func getMe() -> Observable<Mutation> {
    getMeUseCase.execute()
      .asObservable()
      .flatMap { _ -> Observable<Mutation> in .empty() }
  }
}


// MARK: Date

extension HomeViewReactor {

  private func sortLinkList(linkList: [Link]) -> [Link] {
    linkList.sorted { link1, link2 in
      // Date
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

      guard let date1 = dateFormatter.date(from: link1.createdAt),
            let date2 = dateFormatter.date(from: link2.createdAt)
      else { return false }

      return date1 > date2
    }
  }
}

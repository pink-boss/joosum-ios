//
//  HomeBuilder.swift
//  Presentation
//
//  Created by 박천송 on 2023/07/05.
//

import Foundation
import UIKit

import Domain
import PresentationInterface
import PBAnalyticsInterface

struct HomeDependency {
  let analytics: PBAnalytics
  let folderRepository: FolderRepository
  let linkRepository: LinkRepository
  let loginRepository: LoginRepository
  let createLinkBuilder: CreateLinkBuildable
  let createFolderBuilder: CreateFolderBuildable
  let folderDetailBuilder: FolderDetailBuildable
  let webBuilder: PBWebBuildable
}

final class HomeBuilder: HomeBuildable {

  private let dependency: HomeDependency

  init(dependency: HomeDependency) {
    self.dependency = dependency
  }

  func build(payload: HomePayload) -> UIViewController {
    let reactor = HomeViewReactor(
      analytics: dependency.analytics,
      fetchLinkListUseCase: FetchAllLinksUseCaseImpl(
        linkRepository: dependency.linkRepository
      ),
      fetchFolderListUseCase: FetchFolderListUseCaseImpl(
        folderRepository: dependency.folderRepository
      ),
      getMeUseCase: GetMeUsecaseImpl(
        loginRepository: dependency.loginRepository
      ),
      getLinkListUseCase: GetAllLinksUseCaseImpl(
        linkRepository: dependency.linkRepository
      ),
      getFolderListUseCase: GetFolderListUseCaseImpl(
        folderRepository: dependency.folderRepository
      ),
      readLinkUseCase: ReadLinkUseCaseImpl(
        linkRepository: dependency.linkRepository
      )
    )

    let viewController = HomeViewController(
      reactor: reactor,
      analytics: dependency.analytics,
      createLinkBuilder: dependency.createLinkBuilder,
      createFolderBuilder: dependency.createFolderBuilder,
      folderDetailBuilder: dependency.folderDetailBuilder,
      webBuilder: dependency.webBuilder
    )

    return viewController
  }
}

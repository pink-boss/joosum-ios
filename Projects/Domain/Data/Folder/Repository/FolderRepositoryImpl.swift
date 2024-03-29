//
//  FolderRepositoryImpl.swift
//  Data
//
//  Created by 박천송 on 2023/07/07.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import PBNetworking

class FolderRepositoryImpl: FolderRepository {

  private let networking: PBNetworking<FolderAPI>

  private var folderListBehaviorRelay = BehaviorRelay<FolderList>(value: .init(folders: [], totalLinkCount: 0))

  init(networking: PBNetworking<FolderAPI>) {
    self.networking = networking
  }

  func getFolderList() -> FolderList {
    return folderListBehaviorRelay.value
  }

  func bindFolderList() -> BehaviorRelay<FolderList> {
    return folderListBehaviorRelay
  }

  func createFolder(
    backgroundColor: String,
    title: String,
    titleColor: String,
    illustration: String?
  ) -> Single<Folder> {
    let target = FolderAPI
      .createFolder(.init(
        backgroundColor: backgroundColor,
        illustration: illustration,
        title: title,
        titleColor: titleColor
      ))

    return networking.request(target: target)
      .map(FolderDTO.self)
      .map { $0.toDomain() }
  }

  func fetchFolderList(sort: String) -> Single<FolderList> {
    let target = FolderAPI.fetchFolderList(sort: sort)

    return networking.request(target: target)
      .map(FolderListResponse.self)
      .map { [weak self] folderList in
        self?.folderListBehaviorRelay.accept(folderList.toDomain())
        return folderList.toDomain()
      }
  }

  func updateFolder(
    id: String,
    backgroundColor: String,
    title: String,
    titleColor: String,
    illustration: String?
  ) -> Single<Folder> {
    let target = FolderAPI.updateFolder(
      id: id,
      request: .init(
        backgroundColor: backgroundColor,
        illustration: illustration,
        title: title,
        titleColor: titleColor
      )
    )

    return networking.request(target: target)
      .map(FolderDTO.self)
      .map { $0.toDomain() }
  }

  func deleteFolder(id: String) -> Single<Void> {
    let target = FolderAPI.deleteFolder(id: id)

    return networking.request(target: target)
      .map { _ in }
  }
}

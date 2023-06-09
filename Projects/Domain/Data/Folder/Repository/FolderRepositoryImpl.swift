//
//  FolderRepositoryImpl.swift
//  Data
//
//  Created by 박천송 on 2023/07/07.
//

import Foundation

import RxSwift

import Domain
import PBNetworking

class FolderRepositoryImpl: FolderRepository {

  private let networking: PBNetworking<FolderAPI>

  init(networking: PBNetworking<FolderAPI>) {
    self.networking = networking
  }

  func createFolder(
    backgroundColor: String,
    title: String,
    titleColor: String,
    illustration: String?
  ) -> Single<Void> {
    let target = FolderAPI
      .createFolder(.init(
        backgroundColor: backgroundColor,
        illustration: illustration,
        title: title,
        titleColor: titleColor
      ))

    return networking.request(target: target)
      .map { _ in }
  }

  func fetchFolderList(sort: String) -> Single<[Folder]> {
    let target = FolderAPI.fetchFolderList(sort: sort)

    return networking.request(target: target)
      .map(FolderListResponse.self)
      .map { $0.toDomain() }
  }
}

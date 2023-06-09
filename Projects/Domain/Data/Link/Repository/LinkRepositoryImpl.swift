//
//  LinkRepositoryImpl.swift
//  Data
//
//  Created by 박천송 on 2023/07/11.
//

import Foundation

import RxSwift

import Domain
import PBNetworking

final class LinkRepositoryImpl: LinkRepository {

  private let networking: PBNetworking<LinkAPI>

  init(networking: PBNetworking<LinkAPI>) {
    self.networking = networking
  }

  func createLink(linkBookId: String, title: String, url: String, thumbnailURL: String?, tags: [String]) -> Single<Void> {
    let target = LinkAPI
      .createLink(.init(
        linkBookId: linkBookId,
        title: title,
        url: url,
        thumbnailURL: thumbnailURL,
        tags: tags
      ))

    return networking.request(target: target)
      .map { _ in }
  }

  func fetchAllLinks() -> Single<[Link]> {
    let target = LinkAPI.fetchAll

    return networking.request(target: target)
      .map([LinkDTO].self)
      .map { $0.map { dtos in dtos.toDomain() } }
  }

  func fetchLinksInLinkBook(linkBookID: String) -> Single<[Link]> {
    let target = LinkAPI.fetchLinksInLinkBook(linkBookID)

    return networking.request(target: target)
      .map([LinkDTO].self)
      .map { $0.map { dtos in dtos.toDomain() } }
  }
}

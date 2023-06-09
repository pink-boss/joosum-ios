//
//  Link.swift
//  Domain
//
//  Created by 박천송 on 2023/07/07.
//

import Foundation

public struct Link: Hashable {
  public let id: String
  public let linkBookId: String
  public let userId: String

  public let readCount: Int
  public let title: String
  public let url: String
  public let thumbnailURL: String?
  public let tags: [String]

  public let createdAt: String
  public let lastReadAt: String
  public let updatedAt: String

  public init(
    id: String,
    linkBookId: String,
    userId: String,
    readCount: Int,
    title: String,
    url: String,
    thumbnailURL: String?,
    tags: [String],
    createdAt: String,
    lastReadAt: String,
    updatedAt: String
  ) {
    self.id = id
    self.linkBookId = linkBookId
    self.userId = userId
    self.readCount = readCount
    self.title = title
    self.url = url
    self.thumbnailURL = thumbnailURL
    self.tags = tags
    self.createdAt = createdAt
    self.lastReadAt = lastReadAt
    self.updatedAt = updatedAt
  }
}

//
//  ShareSelectTagEvent.swift
//  ShareExtension
//
//  Created by 박천송 on 2023/10/17.
//

import Foundation

import PBAnalyticsInterface

enum ShareSelectTagEvent {
  case click(component: ShareSelectTagClickComponent)
  case shown
}

// MARK: PBAnalyticsType

extension ShareSelectTagEvent: PBAnalyticsType {
  var name: String {
    switch self {
    case .click:
      return PBAnalyticsEventNameBuilder()
        .action(with: .clicked)
        .screen(with: "shareSelectTag")
        .version(with: 1)
        .build()

    case .shown:
      return PBAnalyticsEventNameBuilder()
        .action(with: .shown)
        .screen(with: "shareSelectTag")
        .version(with: 1)
        .build()
    }
  }

  var parameters: [String: Any]? {
    switch self {
    case .click(let component):
      return PBAnalyticsParameterBuilder()
        .component(with: component.rawValue)
        .build()

    case .shown:
      return nil
    }
  }
}

enum ShareSelectTagClickComponent: String {
  case saveTag
  case close
  case deleteTag
  case editTag
  case tagInput
}




//
//  TargetDependency+.swift
//  ProjectDescriptionHelpers
//
//  Created by 박천송 on 2023/04/25.
//

import Foundation

import ProjectDescription

public enum External: String {
  case RxSwift
  case RxCocoa
  case RxRelay
  case RxDataSources
  case Alamofire
  case Moya
  case RxMoya
  case SnapKit
  case Then
  case RxKeyboard
  case Lottie
  case RxGesture
  case SwiftyJSON
  case ReactorKit
  case Swinject
  case SDWebImage
  case Nimble
  case KeychainAccess
  case PanModal
  case Toaster
  case SwiftSoup

  // firebase
  case FirebaseAnalytics
  case FirebaseCrashlytics
  case FirebaseCore
  case FirebaseMessaging
}

extension TargetDependency {
  public static func external(dependency: External)-> TargetDependency {
    .external(name: dependency.rawValue, condition: .when([.ios]))
  }
}

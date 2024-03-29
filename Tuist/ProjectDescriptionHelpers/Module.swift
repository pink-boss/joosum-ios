//
//  ProjectName.swift
//  ProjectDescriptionHelpers
//
//  Created by cheonsong on 2022/09/02.
//

import ProjectDescription

public enum Module: String, CaseIterable {
  case App
  case Domain
  case Presentation
  case DesignSystem
}

public enum CoreModule: String, CaseIterable {
  case PBNetworking
  case PBAnalytics
  case PBLog
  case PBAuth
  case PBUserDefaults
}

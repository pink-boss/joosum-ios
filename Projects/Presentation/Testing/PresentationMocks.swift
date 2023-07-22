///
/// @Generated by Mockolo
///



import Domain
import Foundation
import UIKit
@testable import PresentationInterface


public final class LoginBuildableMock: LoginBuildable {
    public init() { }


    public private(set) var buildCallCount = 0
    public var buildArgValues = [LoginPayload]()
    public var buildHandler: ((LoginPayload) -> (UIViewController))?
    public func build(payload: LoginPayload) -> UIViewController {
        buildCallCount += 1
        buildArgValues.append(payload)
        if let buildHandler = buildHandler {
            return buildHandler(payload)
        }
        return UIViewController()
    }
}

public final class PBWebBuildableMock: PBWebBuildable {
    public init() { }


    public private(set) var buildCallCount = 0
    public var buildArgValues = [PBWebPayload]()
    public var buildHandler: ((PBWebPayload) -> (UIViewController))?
    public func build(payload: PBWebPayload) -> UIViewController {
        buildCallCount += 1
        buildArgValues.append(payload)
        if let buildHandler = buildHandler {
            return buildHandler(payload)
        }
        return UIViewController()
    }
}


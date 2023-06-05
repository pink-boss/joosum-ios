import Foundation

import Swinject

import Domain
import PresentationInterface

// MARK: - PresentationAssembly

public final class PresentationAssembly: Assembly {
  public init() {}

  public func assemble(container: Container) {
    let registerFunctions: [(Container) -> Void] = [
      registerLoginBuilder,
      registerMainTabBuilder,
      registerHomeBuilder,
      registerFolderBuilder,
      registerMyPageBuilder
    ]

    registerFunctions.forEach { function in
      function(container)
    }
  }

  private func registerLoginBuilder(container: Container) {
    container.register(LoginBuildable.self) { resolver in
      LoginBuilder(dependency: .init(
        analytics: resolver.resolve(),
        loginRepository: resolver.resolve(),
        mainTabBuilder: resolver.resolve()
      ))
    }
  }

  private func registerMainTabBuilder(contianer: Container) {
    contianer.register(MainTabBarBuildable.self) { resolver in
      MainTabBarBuilder(dependency: .init(
        homeBuilder: resolver.resolve(),
        folderBuilder: resolver.resolve(),
        myPageBuilder: resolver.resolve()
      ))
    }
  }

  private func registerHomeBuilder(container: Container) {
    container.register(HomeBuildable.self) { _ in
      HomeBuilder(dependency: .init())
    }
  }

  private func registerFolderBuilder(container: Container) {
    container.register(FolderBuildable.self) { _ in
      FolderBuilder(dependency: .init())
    }
  }

  private func registerMyPageBuilder(container: Container) {
    container.register(MyPageBuildable.self) { resolver in
      MyPageBuilder(dependency: .init(
        loginRepository: resolver.resolve()
      ))
    }.initCompleted { resolver, builder in
      builder.configure(loginBuilder: resolver.resolve())
    }
  }
}

// MARK: - Resolver

private extension Resolver {
  func resolve<Service>() -> Service! {
    resolve(Service.self)
  }
}

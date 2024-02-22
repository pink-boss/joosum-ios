import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

extension Project {
  public static let bundleID = "com.pinkboss"
  public static let iosVersion = "14.0"
}

extension Project {
  public static func project(
    name: String,
    targets: [Target] = [],
    additionalFiles: [FileElement] = []
  ) -> Project {

    return Project(
      name: name,
      organizationName: "PinkBoss Inc",
      options: .options(
        textSettings: .textSettings(
          indentWidth: 2,
          tabWidth: 2,
          wrapsLines: true
        )
      ),
      targets: targets,
      additionalFiles: additionalFiles
    )
  }
}

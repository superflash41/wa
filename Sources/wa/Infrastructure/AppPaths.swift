import Foundation

enum AppPaths {
    static let applicationName = "wa"

    static var applicationSupportDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(applicationName, isDirectory: true)
    }

    static var configurationFile: URL {
        applicationSupportDirectory.appendingPathComponent("config.json")
    }

    static var pidFile: URL {
        applicationSupportDirectory.appendingPathComponent("wa.pid")
    }

    static var logDirectory: URL {
        applicationSupportDirectory.appendingPathComponent("logs", isDirectory: true)
    }

    static var launchAgentsDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("LaunchAgents", isDirectory: true)
    }

    static func createDirectory(_ url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
}

import Foundation

enum AppPaths {
    static let applicationName = "wa"

    static func applicationSupportDirectory(createIfNeeded: Bool = true) throws -> URL {
        guard let baseURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw CocoaError(.fileNoSuchFile)
        }

        let directory = baseURL.appendingPathComponent(applicationName, isDirectory: true)
        if createIfNeeded {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    static func configurationFile(createIfNeeded: Bool = true) throws -> URL {
        try applicationSupportDirectory(createIfNeeded: createIfNeeded).appendingPathComponent("config.json")
    }

    static func pidFile(createIfNeeded: Bool = true) throws -> URL {
        try applicationSupportDirectory(createIfNeeded: createIfNeeded).appendingPathComponent("wa.pid")
    }

    static func logDirectory() throws -> URL {
        let directory = try applicationSupportDirectory().appendingPathComponent("logs", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    static var launchAgentsDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("LaunchAgents", isDirectory: true)
    }
}

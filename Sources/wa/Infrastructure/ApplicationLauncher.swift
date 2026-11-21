import Foundation

enum ApplicationLauncher {
    static func currentExecutableURL() throws -> URL {
        if let executableURL = Bundle.main.executableURL {
            return executableURL.standardizedFileURL
        }

        return try FileResolver.resolveExecutable(CommandLine.arguments[0])
    }

    /// Launches `wa app` as a background process. It plays the saved
    /// selection, so callers save a new video before starting.
    static func start() throws {
        let process = Process()
        process.executableURL = try currentExecutableURL()
        process.arguments = ["app"]

        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        try process.run()
    }
}

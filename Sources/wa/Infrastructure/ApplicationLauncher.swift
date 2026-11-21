import Foundation

enum ApplicationLauncher {
    static func currentExecutableURL() throws -> URL {
        if let executableURL = Bundle.main.executableURL {
            return executableURL.standardizedFileURL
        }

        return try FileResolver.resolveExecutable(CommandLine.arguments[0])
    }

    static func start(videoURL: URL?) throws {
        let process = Process()
        process.executableURL = try currentExecutableURL()

        var arguments = ["app"]
        if let videoURL {
            arguments.append(videoURL.path)
        }
        process.arguments = arguments

        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        try process.run()
    }
}

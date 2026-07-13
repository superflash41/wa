import Foundation

enum LaunchAgentError: LocalizedError {
    case launchctlFailed(arguments: [String], message: String)

    var errorDescription: String? {
        switch self {
        case let .launchctlFailed(arguments, message):
            return "launchctl \(arguments.joined(separator: " ")) failed: \(message)"
        }
    }
}

final class LaunchAgentManager {
    private let label = "local.wa.wallpaper-manager"

    var isInstalled: Bool {
        FileManager.default.fileExists(atPath: launchAgentURL.path)
    }

    private var launchAgentURL: URL {
        AppPaths.launchAgentsDirectory.appendingPathComponent("\(label).plist")
    }

    func install(executableURL: URL, loadNow: Bool) throws {
        try FileManager.default.createDirectory(
            at: AppPaths.launchAgentsDirectory,
            withIntermediateDirectories: true
        )

        let logDirectory = try AppPaths.logDirectory()
        let plist: [String: Any] = [
            "Label": label,
            "ProgramArguments": [
                executableURL.standardizedFileURL.path,
                "app"
            ],
            "RunAtLoad": true,
            "KeepAlive": true,
            "ProcessType": "Interactive",
            "LimitLoadToSessionType": "Aqua",
            "StandardOutPath": logDirectory.appendingPathComponent("launchagent.out.log").path,
            "StandardErrorPath": logDirectory.appendingPathComponent("launchagent.err.log").path
        ]

        let data = try PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .xml,
            options: 0
        )
        try data.write(to: launchAgentURL, options: .atomic)

        if loadNow {
            _ = try stop()
            try launchctl(["bootstrap", guiDomain, launchAgentURL.path])
        }
    }

    func uninstall() throws {
        if FileManager.default.fileExists(atPath: launchAgentURL.path) {
            try FileManager.default.removeItem(at: launchAgentURL)
        }

        _ = try stop()
    }

    @discardableResult
    func stop() throws -> Bool {
        do {
            try launchctl(["bootout", "\(guiDomain)/\(label)"])
            return true
        } catch {
            return false
        }
    }

    private var guiDomain: String {
        "gui/\(getuid())"
    }

    private func launchctl(_ arguments: [String]) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = arguments

        let errorPipe = Pipe()
        process.standardOutput = FileHandle.nullDevice
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let data = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let message = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                ?? "exit code \(process.terminationStatus)"
            throw LaunchAgentError.launchctlFailed(arguments: arguments, message: message)
        }
    }
}

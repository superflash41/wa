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
    static let label = "local.wa.wallpaper-manager"

    var isInstalled: Bool {
        FileManager.default.fileExists(atPath: launchAgentURL.path)
    }

    var isLoaded: Bool {
        serviceDescription() != nil
    }

    /// The pid launchd reports for the agent, while the agent's app is running.
    var runningPID: pid_t? {
        serviceDescription().flatMap(Self.pid(fromServiceDescription:))
    }

    /// True when launchd started this process for the agent.
    var managesCurrentProcess: Bool {
        runningPID == getpid()
    }

    private var launchAgentURL: URL {
        AppPaths.launchAgentsDirectory.appendingPathComponent("\(Self.label).plist")
    }

    private var guiDomain: String {
        "gui/\(getuid())"
    }

    private var serviceTarget: String {
        "\(guiDomain)/\(Self.label)"
    }

    static func propertyList(executableURL: URL, logDirectory: URL) -> [String: Any] {
        [
            "Label": label,
            "ProgramArguments": [
                executableURL.standardizedFileURL.path,
                "app"
            ],
            "RunAtLoad": true,
            // restart after a crash, but let quit from the menu bar stay quit
            "KeepAlive": ["SuccessfulExit": false],
            "ProcessType": "Interactive",
            "LimitLoadToSessionType": "Aqua",
            "StandardOutPath": logDirectory.appendingPathComponent("launchagent.out.log").path,
            "StandardErrorPath": logDirectory.appendingPathComponent("launchagent.err.log").path
        ]
    }

    static func pid(fromServiceDescription description: String) -> pid_t? {
        // top-level fields of `launchctl print` are indented by exactly one tab
        for line in description.split(separator: "\n") where line.hasPrefix("\tpid = ") {
            return pid_t(line.dropFirst("\tpid = ".count).trimmingCharacters(in: .whitespaces))
        }

        return nil
    }

    func install(executableURL: URL, loadNow: Bool) throws {
        try AppPaths.createDirectory(AppPaths.launchAgentsDirectory)
        try AppPaths.createDirectory(AppPaths.logDirectory)

        let plist = Self.propertyList(executableURL: executableURL, logDirectory: AppPaths.logDirectory)
        let data = try PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .xml,
            options: 0
        )
        try data.write(to: launchAgentURL, options: .atomic)

        // reloading the job from the app it runs would terminate that app; the
        // loaded job already runs it and the new plist applies at next login
        if loadNow, !managesCurrentProcess {
            try load()
        }
    }

    /// Removes the plist. When called from the app the agent runs, the job
    /// stays loaded until logout so the wallpaper keeps playing.
    func uninstall() throws {
        if isInstalled {
            try FileManager.default.removeItem(at: launchAgentURL)
        }

        if !managesCurrentProcess {
            stop()
        }
    }

    /// Loads the installed plist again, replacing a job that is already loaded.
    func load() throws {
        stop()
        try launchctl(["bootstrap", guiDomain, launchAgentURL.path])
    }

    /// Unloads the agent, which also terminates the app it runs.
    @discardableResult
    func stop() -> Bool {
        guard isLoaded else {
            return false
        }

        _ = try? launchctl(["bootout", serviceTarget])

        // bootout returns before the app exits, and bootstrapping the label
        // again while it is still loaded fails
        let deadline = Date().addingTimeInterval(5)
        while isLoaded, Date() < deadline {
            usleep(100_000)
        }

        return true
    }

    private func serviceDescription() -> String? {
        try? launchctl(["print", serviceTarget])
    }

    @discardableResult
    private func launchctl(_ arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        // drain stdout before waiting, so a long `print` cannot fill the pipe
        let output = outputPipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let data = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let message = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                ?? "exit code \(process.terminationStatus)"
            throw LaunchAgentError.launchctlFailed(arguments: arguments, message: message)
        }

        return String(data: output, encoding: .utf8) ?? ""
    }
}

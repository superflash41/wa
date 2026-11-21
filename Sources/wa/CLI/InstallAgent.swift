import ArgumentParser
import Foundation

struct InstallAgent: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "install-agent",
        abstract: "Install a user LaunchAgent so wa starts at login and restarts if it exits."
    )

    @Argument(help: "Optional path to a local video file to select before installing.")
    var video: String?

    @Option(name: .long, help: "Path to the wa executable the LaunchAgent should run.")
    var executable: String?

    mutating func run() throws {
        let store = ConfigurationStore()

        if let video {
            let videoURL = try FileResolver.resolveFile(video)
            _ = try store.selectWallpaper(videoURL)
        }

        let executableURL = try executable.map(FileResolver.resolveExecutable)
            ?? ApplicationLauncher.currentExecutableURL()

        try LaunchAgentManager().install(executableURL: executableURL, loadNow: true)
        print("installed always-on LaunchAgent")
    }
}

struct UninstallAgent: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "uninstall-agent",
        abstract: "Remove the user LaunchAgent."
    )

    mutating func run() throws {
        try LaunchAgentManager().uninstall()
        print("removed always-on LaunchAgent")
    }
}

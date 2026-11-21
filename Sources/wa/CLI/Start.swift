import ArgumentParser
import Foundation

struct Start: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Start wa in the background, through the always-on LaunchAgent when it is installed."
    )

    @Argument(help: "Optional path to a local video file. If omitted, the saved selection is used.")
    var video: String?

    mutating func run() throws {
        let store = ConfigurationStore()

        if let video {
            try store.selectWallpaper(FileResolver.resolveFile(video))
        }

        let launchAgent = LaunchAgentManager()
        launchAgent.stop()
        PIDStore.terminateRunningProcess()

        let startedBy: String
        if launchAgent.isInstalled {
            // the agent also restarts wa after a crash, so prefer it to a plain process
            try launchAgent.load()
            startedBy = "through the always-on LaunchAgent"
        } else {
            try ApplicationLauncher.start()
            startedBy = "in the background"
        }

        if store.load().selectedWallpaperPath == nil {
            print("started wa \(startedBy). Use the menu bar to select a wallpaper.")
        } else {
            print("started wa \(startedBy)")
        }
    }
}

import ArgumentParser
import Foundation

struct Start: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Start wa in the background."
    )

    @Argument(help: "Optional path to a local video file. If omitted, the saved selection is used.")
    var video: String?

    mutating func run() throws {
        let store = ConfigurationStore()
        let selectedURL = try video.map(FileResolver.resolveFile)

        if let selectedURL {
            _ = try store.selectWallpaper(selectedURL)
        }

        LaunchAgentManager().stop()
        PIDStore.terminateRunningProcess()
        try ApplicationLauncher.start(videoURL: selectedURL)

        if selectedURL == nil, store.load().selectedWallpaperPath == nil {
            print("started wa in the background. Use the menu bar to select a wallpaper.")
        } else {
            print("started wa in the background")
        }
    }
}

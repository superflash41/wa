import AppKit
import Foundation

final class ApplicationRunner {
    func run(videoPath: String?) throws {
        let store = ConfigurationStore()
        let initialVideoURL = try videoPath.map(WallpaperFile.resolve)

        if let initialVideoURL {
            _ = try store.selectWallpaper(initialVideoURL)
        }

        terminateOtherInstanceIfNeeded()

        try PIDStore.writeCurrentProcessID()

        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        let delegate = WallpaperApplicationDelegate(configurationStore: store)
        app.delegate = delegate
        app.run()
    }

    private func terminateOtherInstanceIfNeeded() {
        guard let runningPID = PIDStore.runningPID(), runningPID != getpid() else {
            return
        }

        _ = kill(runningPID, SIGTERM)

        for _ in 0..<20 {
            if kill(runningPID, 0) != 0 {
                return
            }

            usleep(100_000)
        }
    }
}

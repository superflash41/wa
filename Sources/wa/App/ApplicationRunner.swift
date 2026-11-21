import AppKit
import Foundation

final class ApplicationRunner {
    func run(videoPath: String?) throws {
        let store = ConfigurationStore()
        let initialVideoURL = try videoPath.map(FileResolver.resolveFile)

        if let initialVideoURL {
            _ = try store.selectWallpaper(initialVideoURL)
        }

        // only one wallpaper app runs at a time, so replace the previous one
        PIDStore.terminateRunningProcess()
        try PIDStore.writeCurrentProcess()

        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        let delegate = WallpaperApplicationDelegate(configurationStore: store)
        app.delegate = delegate

        // app.delegate is weak, so keep the delegate and signal sources alive
        // for as long as the run loop runs
        withExtendedLifetime((delegate, terminationSignalSources())) {
            app.run()
        }
    }

    /// Turns SIGTERM and SIGINT into a normal AppKit quit, so `wa stop`,
    /// `launchctl bootout` and ctrl-c clean up and exit with status 0.
    private func terminationSignalSources() -> [DispatchSourceSignal] {
        [SIGTERM, SIGINT].map { signalNumber in
            signal(signalNumber, SIG_IGN)

            let source = DispatchSource.makeSignalSource(signal: signalNumber, queue: .main)
            source.setEventHandler {
                NSApplication.shared.terminate(nil)
            }
            source.resume()
            return source
        }
    }
}

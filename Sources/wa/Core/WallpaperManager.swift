import AppKit

final class WallpaperManager {
    private(set) var isPaused = false
    private var windows: [WallpaperWindow] = []
    private var videoURL: URL?
    private var screenObserver: NSObjectProtocol?

    init() {
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshDisplays()
        }
    }

    deinit {
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }

        closeWindows()
    }

    func setWallpaper(_ url: URL) {
        videoURL = url
        isPaused = false
        refreshDisplays()
    }

    func refreshDisplays() {
        closeWindows()

        guard let videoURL else {
            return
        }

        windows = NSScreen.screens.map { screen in
            WallpaperWindow(
                videoURL: videoURL,
                screen: screen,
                shouldPlay: { [weak self] in self?.isPaused == false }
            )
        }
    }

    func togglePlayback() {
        if isPaused {
            resume()
        } else {
            pause()
        }
    }

    private func pause() {
        isPaused = true
        windows.forEach { $0.pause() }
    }

    private func resume() {
        isPaused = false
        windows.forEach { $0.playIfVisible() }
    }

    private func closeWindows() {
        windows.forEach { $0.close() }
        windows.removeAll()
    }
}

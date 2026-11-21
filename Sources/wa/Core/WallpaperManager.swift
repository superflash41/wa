import AppKit

final class WallpaperManager {
    private(set) var isPaused = false
    private var windows: [WallpaperWindow] = []
    private var loop: LoopingPlayer?
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
        loop = LoopingPlayer(url: url)
        isPaused = false
        refreshDisplays()
    }

    func refreshDisplays() {
        closeWindows()

        guard let loop else {
            return
        }

        windows = NSScreen.screens.map { screen in
            WallpaperWindow(screen: screen, player: loop.player) { [weak self] in
                self?.updatePlayback()
            }
        }

        updatePlayback()
    }

    func togglePlayback() {
        isPaused.toggle()
        updatePlayback()
    }

    /// Plays while the user has not paused and at least one display shows the
    /// wallpaper, so a fully covered desktop costs no decoding.
    private func updatePlayback() {
        guard let loop else {
            return
        }

        if !isPaused, windows.contains(where: \.isVisibleOnScreen) {
            loop.play()
        } else {
            loop.pause()
        }
    }

    private func closeWindows() {
        windows.forEach { $0.close() }
        windows.removeAll()
    }
}

import AppKit

final class WallpaperManager {
    private(set) var isPaused = false
    private var windows: [CGDirectDisplayID: WallpaperWindow] = [:]
    private var loop: LoopingPlayer?
    private var screenObserver: NSObjectProtocol?

    init() {
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.syncDisplays()
        }
    }

    deinit {
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }

        closeWindows()
    }

    func setWallpaper(_ url: URL) {
        let loop = LoopingPlayer(url: url)
        self.loop = loop
        isPaused = false

        windows.values.forEach { $0.show(loop.player) }
        syncDisplays()
    }

    /// Matches the windows to the connected displays: adds windows for new
    /// displays, closes windows for removed ones and moves the rest in place,
    /// so a display change does not restart playback.
    func syncDisplays() {
        guard let loop else {
            closeWindows()
            return
        }

        var screens: [CGDirectDisplayID: NSScreen] = [:]
        for screen in NSScreen.screens {
            if let displayID = screen.displayID {
                screens[displayID] = screen
            }
        }

        for (displayID, window) in windows where screens[displayID] == nil {
            window.close()
            windows[displayID] = nil
        }

        for (displayID, screen) in screens {
            if let window = windows[displayID] {
                window.move(to: screen)
            } else {
                windows[displayID] = WallpaperWindow(screen: screen, player: loop.player) { [weak self] in
                    self?.updatePlayback()
                }
            }
        }

        updatePlayback()
    }

    /// Recreates every window, for when a display ends up in a bad state.
    func reloadDisplays() {
        closeWindows()
        syncDisplays()
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

        if !isPaused, windows.values.contains(where: \.isVisibleOnScreen) {
            loop.play()
        } else {
            loop.pause()
        }
    }

    private func closeWindows() {
        windows.values.forEach { $0.close() }
        windows.removeAll()
    }
}

private extension NSScreen {
    var displayID: CGDirectDisplayID? {
        (deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value
    }
}

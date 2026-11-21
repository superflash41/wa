import AppKit
import AVFoundation

/// Borderless desktop-level window that shows the shared wallpaper player on
/// one display.
final class WallpaperWindow: NSWindow {
    private let playerLayer = AVPlayerLayer()
    private var occlusionObserver: NSObjectProtocol?

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    var isVisibleOnScreen: Bool {
        occlusionState.contains(.visible)
    }

    init(screen: NSScreen, player: AVPlayer, onVisibilityChange: @escaping () -> Void) {
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        // the manager owns these windows; releasing on close as well over-releases
        // them and crashes in objc_release on the next display change
        isReleasedWhenClosed = false

        configureWindow()
        configurePlayerLayer(player: player)

        occlusionObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didChangeOcclusionStateNotification,
            object: self,
            queue: .main
        ) { _ in
            onVisibilityChange()
        }

        orderFrontRegardless()
    }

    deinit {
        if let occlusionObserver {
            NotificationCenter.default.removeObserver(occlusionObserver)
        }
    }

    private func configureWindow() {
        level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)))
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        ignoresMouseEvents = true
        backgroundColor = .clear
        isOpaque = false
    }

    private func configurePlayerLayer(player: AVPlayer) {
        let rootView = NSView(frame: CGRect(origin: .zero, size: frame.size))
        rootView.wantsLayer = true

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        rootView.layer = playerLayer

        contentView = rootView
    }
}

import AppKit
import AVFoundation

final class WallpaperWindow: NSWindow {
    private let player: AVPlayer
    private let shouldPlay: () -> Bool
    private var endObserver: NSObjectProtocol?
    private var occlusionObserver: NSObjectProtocol?

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    init(videoURL: URL, screen: NSScreen, shouldPlay: @escaping () -> Bool) {
        self.player = AVPlayer(url: videoURL)
        self.shouldPlay = shouldPlay

        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        configureWindow()
        configurePlayerLayer(screen: screen)
        configureObservers()

        orderFrontRegardless()
        playIfVisible()
    }

    deinit {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }

        if let occlusionObserver {
            NotificationCenter.default.removeObserver(occlusionObserver)
        }
    }

    func pause() {
        player.pause()
    }

    func playIfVisible() {
        guard shouldPlay(), occlusionState.contains(.visible) else {
            player.pause()
            return
        }

        player.play()
    }

    private func configureWindow() {
        level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)))
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        ignoresMouseEvents = true
        backgroundColor = .clear
        isOpaque = false
    }

    private func configurePlayerLayer(screen: NSScreen) {
        player.isMuted = true
        player.actionAtItemEnd = .none

        let rootView = NSView(frame: CGRect(origin: .zero, size: screen.frame.size))
        rootView.wantsLayer = true

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = rootView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        rootView.layer = playerLayer

        contentView = rootView
    }

    private func configureObservers() {
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player.seek(to: .zero)
            self?.playIfVisible()
        }

        occlusionObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didChangeOcclusionStateNotification,
            object: self,
            queue: .main
        ) { [weak self] _ in
            self?.playIfVisible()
        }
    }
}

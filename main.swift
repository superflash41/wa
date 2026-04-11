import AppKit
import AVFoundation

class WallpaperManager {
    var win: [WallpaperWindow] = []
    let videoURL: URL

    init(videoURL: URL) {
        self.videoURL = videoURL
        setupWallpaper()

        // watch for monitor plug/unplug
        NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { [weak self] _ in
            self?.setupWallpaper()
        }     
    }

    func setupWallpaper() {
        win.forEach { $0.close() }
        win = NSScreen.screens.map { WallpaperWindow(videoURL: videoURL, screen: $0) }
    }
}

class WallpaperWindow: NSWindow {
    var player: AVPlayer?

    init(videoURL: URL, screen: NSScreen) {
        super.init(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)

        // level below desktop icons
        self.level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)))
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        self.ignoresMouseEvents = true
        self.backgroundColor = .clear
        
        player = AVPlayer(url: videoURL)
        player?.isMuted = true
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.contentView!.bounds
        playerLayer.videoGravity = .resizeAspectFill
        
        self.contentView?.wantsLayer = true
        self.contentView?.layer = playerLayer
        
        // loop
        player?.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { _ in
            self.player?.seek(to: .zero)
            self.player?.play()
        }

        // stop playing if window is covered
        NotificationCenter.default.addObserver(forName: NSWindow.didChangeOcclusionStateNotification, object: self, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if self.occlusionState.contains(.visible) {
                self.player?.play()
            } else {
                self.player?.pause()
            }
        }

        self.makeKeyAndOrderFront(nil)
        player?.play()
    }
}

// let's go
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let url = URL(fileURLWithPath: CommandLine.arguments[1])
let manager = WallpaperManager(videoURL: url)
app.run()
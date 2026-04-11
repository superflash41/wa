import AppKit
import AVFoundation
import ArgumentParser

@main
struct Wa: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "macos live wallpaper manager",
        version: "0.1.0",
        subcommands: [Start.self, Stop.self, Status.self, Daemon.self],
        defaultSubcommand: Start.self
    )
}

struct Start: ParsableCommand {
    @Argument(help: "path to video file")
    var video: String?

    mutating func run() throws {
        // stop running instance
        var stopCmd = Stop()
        try? stopCmd.run()
        
        let executablePath = Bundle.main.executableURL ?? URL(fileURLWithPath: CommandLine.arguments[0])
        let process = Process()
        process.executableURL = executablePath
        
        var args = ["daemon"]
        if let video = video {
            args.append(video)
        }
        process.arguments = args
        
        // detach output
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        
        try process.run()
        print("started wa in background")
    }
}

struct Daemon: ParsableCommand {
    @Argument(help: "path to video file")
    var video: String?

    mutating func run() throws {
        let path = video ?? NSString(string: "~/Downloads/fallback.mp4").expandingTildeInPath
        let url = URL(fileURLWithPath: path)
        
        // get pid to trace later
        let pid = String(getpid())
        try? pid.write(toFile: "/tmp/wa.pid", atomically: true, encoding: .utf8)
        
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let delegate = AppDelegate(videoURL: url)
        app.delegate = delegate
        app.run()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var manager: WallpaperManager?
    var statusItem: NSStatusItem?
    let videoURL: URL
    
    init(videoURL: URL) {
        self.videoURL = videoURL
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        manager = WallpaperManager(videoURL: videoURL)
        
        setupMenu()
    }
    
    func setupMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            if #available(macOS 11.0, *) {
                button.image = NSImage(systemSymbolName: "display", accessibilityDescription: "wa")
            } else {
                button.title = "wa"
            }
        }
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Toggle Pause", action: #selector(togglePause), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit wa", action: #selector(quit), keyEquivalent: ""))
        
        statusItem?.menu = menu
    }
    
    @objc func togglePause() {
        manager?.win.forEach {
            if let player = $0.player {
                if player.rate == 0 {
                    player.play()
                } else {
                    player.pause()
                }
            }
        }
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        try? FileManager.default.removeItem(atPath: "/tmp/wa.pid")
    }
}

struct Stop: ParsableCommand {
    mutating func run() throws {
        if let pidString = try? String(contentsOfFile: "/tmp/wa.pid"), let pid = Int32(pidString) {
            kill(pid, SIGINT)
            try? FileManager.default.removeItem(atPath: "/tmp/wa.pid")
            print("stopped wa")
        } else {
            print("wa is not running")
        }
    }
}

struct Status: ParsableCommand {
    mutating func run() throws {
        if let pidString = try? String(contentsOfFile: "/tmp/wa.pid"), let pid = Int32(pidString) {
             if kill(pid, 0) == 0 {
                 print("wa is running (pid: \(pid))")
                 return
             }
        }
        print("wa is not running")
    }
}

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
        player?.isMuted = true // mute audio, preventing device from recognizing source
        
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
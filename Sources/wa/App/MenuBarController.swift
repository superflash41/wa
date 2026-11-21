import AppKit
import Foundation
import UniformTypeIdentifiers

final class MenuBarController: NSObject {
    private let statusItem: NSStatusItem
    private let configurationStore: ConfigurationStore
    private let launchAgentManager: LaunchAgentManager
    private weak var wallpaperManager: WallpaperManager?

    init(
        configurationStore: ConfigurationStore,
        wallpaperManager: WallpaperManager,
        launchAgentManager: LaunchAgentManager = LaunchAgentManager()
    ) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.configurationStore = configurationStore
        self.wallpaperManager = wallpaperManager
        self.launchAgentManager = launchAgentManager
        super.init()

        configureButton()
        rebuildMenu()
    }

    private func configureButton() {
        guard let button = statusItem.button else {
            return
        }

        if let image = NSImage(systemSymbolName: "display", accessibilityDescription: "wa") {
            image.isTemplate = true
            button.image = image
        } else {
            button.title = "wa"
        }
    }

    private func rebuildMenu() {
        let configuration = configurationStore.load()
        let menu = NSMenu()

        let currentTitle = configuration.selectedWallpaperPath
            .map { "Current: \(URL(fileURLWithPath: $0).lastPathComponent)" }
            ?? "No Wallpaper Selected"
        let currentItem = NSMenuItem(title: currentTitle, action: nil, keyEquivalent: "")
        currentItem.isEnabled = false
        menu.addItem(currentItem)

        menu.addItem(targetedItem(title: "Select Wallpaper...", action: #selector(selectWallpaper)))

        let recentPaths = configuration.recentWallpaperPaths.filter {
            FileManager.default.fileExists(atPath: $0)
        }

        if !recentPaths.isEmpty {
            let recentItem = NSMenuItem(title: "Recent Wallpapers", action: nil, keyEquivalent: "")
            let recentMenu = NSMenu()

            for path in recentPaths {
                let item = targetedItem(
                    title: URL(fileURLWithPath: path).lastPathComponent,
                    action: #selector(selectRecentWallpaper(_:))
                )
                item.representedObject = path
                item.toolTip = path
                item.state = path == configuration.selectedWallpaperPath ? .on : .off
                recentMenu.addItem(item)
            }

            menu.setSubmenu(recentMenu, for: recentItem)
            menu.addItem(recentItem)
        }

        menu.addItem(NSMenuItem.separator())

        let pauseTitle = wallpaperManager?.isPaused == true ? "Resume" : "Pause"
        menu.addItem(targetedItem(title: pauseTitle, action: #selector(togglePlayback)))
        menu.addItem(targetedItem(title: "Refresh Displays", action: #selector(refreshDisplays)))

        menu.addItem(NSMenuItem.separator())

        let agentTitle = launchAgentManager.isInstalled ? "Disable Always On" : "Enable Always On"
        menu.addItem(targetedItem(title: agentTitle, action: #selector(toggleAlwaysOn)))

        menu.addItem(NSMenuItem.separator())
        menu.addItem(targetedItem(title: "Quit wa", action: #selector(quit)))

        statusItem.menu = menu
    }

    private func targetedItem(title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    @objc private func selectWallpaper() {
        NSApplication.shared.activate(ignoringOtherApps: true)

        let panel = NSOpenPanel()
        panel.title = "Select Wallpaper Video"
        panel.message = "Choose a local video to loop as your desktop wallpaper."
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.movie]

        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }

        applyWallpaper(url)
    }

    @objc private func selectRecentWallpaper(_ sender: NSMenuItem) {
        guard let path = sender.representedObject as? String else {
            return
        }

        applyWallpaper(URL(fileURLWithPath: path))
    }

    @objc private func togglePlayback() {
        wallpaperManager?.togglePlayback()
        rebuildMenu()
    }

    @objc private func refreshDisplays() {
        wallpaperManager?.reloadDisplays()
    }

    @objc private func toggleAlwaysOn() {
        do {
            if launchAgentManager.isInstalled {
                try launchAgentManager.uninstall()
            } else {
                try launchAgentManager.install(
                    executableURL: ApplicationLauncher.currentExecutableURL(),
                    loadNow: true
                )
            }

            rebuildMenu()
        } catch {
            presentError(error)
        }
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    private func applyWallpaper(_ url: URL) {
        do {
            let resolvedURL = try FileResolver.resolveFile(url.path)
            _ = try configurationStore.selectWallpaper(resolvedURL)
            wallpaperManager?.setWallpaper(resolvedURL)
            rebuildMenu()
        } catch {
            presentError(error)
        }
    }

    private func presentError(_ error: Error) {
        let alert = NSAlert(error: error)
        alert.runModal()
    }
}

import AppKit

final class WallpaperApplicationDelegate: NSObject, NSApplicationDelegate {
    private let configurationStore: ConfigurationStore
    private var wallpaperManager: WallpaperManager?
    private var menuBarController: MenuBarController?

    init(configurationStore: ConfigurationStore) {
        self.configurationStore = configurationStore
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let manager = WallpaperManager()
        wallpaperManager = manager

        if let selectedPath = configurationStore.load().selectedWallpaperPath,
           FileManager.default.fileExists(atPath: selectedPath) {
            manager.setWallpaper(URL(fileURLWithPath: selectedPath))
        }

        menuBarController = MenuBarController(
            configurationStore: configurationStore,
            wallpaperManager: manager
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        try? PIDStore.remove()
    }
}

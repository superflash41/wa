import Foundation

final class ConfigurationStore {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileURL: URL = AppPaths.configurationFile) {
        self.fileURL = fileURL
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func load() -> WallpaperConfiguration {
        guard let data = try? Data(contentsOf: fileURL) else {
            return .empty
        }

        do {
            return try decoder.decode(WallpaperConfiguration.self, from: data)
        } catch {
            setAsideUnreadableFile(reason: error)
            return .empty
        }
    }

    @discardableResult
    func selectWallpaper(_ url: URL) throws -> WallpaperConfiguration {
        var configuration = load()
        configuration.select(url.standardizedFileURL.path)
        try save(configuration)
        return configuration
    }

    /// Moves an unreadable config to `config.json.invalid`, so the next save
    /// does not silently replace a file the user may want to fix by hand.
    private func setAsideUnreadableFile(reason: Error) {
        let path = fileURL.path
        let backupURL = fileURL.appendingPathExtension("invalid")

        do {
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try FileManager.default.removeItem(at: backupURL)
            }

            try FileManager.default.moveItem(at: fileURL, to: backupURL)
            Log.configuration.error("moved unreadable \(path, privacy: .public) to \(backupURL.lastPathComponent, privacy: .public): \(reason.localizedDescription, privacy: .public)")
        } catch {
            Log.configuration.error("cannot set aside unreadable \(path, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }

    private func save(_ configuration: WallpaperConfiguration) throws {
        let data = try encoder.encode(configuration)
        try AppPaths.createDirectory(fileURL.deletingLastPathComponent())
        try data.write(to: fileURL, options: .atomic)
    }
}

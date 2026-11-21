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
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(WallpaperConfiguration.self, from: data)
        } catch {
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

    private func save(_ configuration: WallpaperConfiguration) throws {
        let data = try encoder.encode(configuration)
        try AppPaths.createDirectory(fileURL.deletingLastPathComponent())
        try data.write(to: fileURL, options: .atomic)
    }
}

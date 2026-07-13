import Foundation

final class ConfigurationStore {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func load() -> WallpaperConfiguration {
        do {
            let fileURL = try AppPaths.configurationFile(createIfNeeded: false)
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(WallpaperConfiguration.self, from: data)
        } catch {
            return .empty
        }
    }

    @discardableResult
    func selectWallpaper(_ url: URL) throws -> WallpaperConfiguration {
        var configuration = load()
        let path = url.standardizedFileURL.path

        configuration.selectedWallpaperPath = path
        configuration.recentWallpaperPaths.removeAll { $0 == path }
        configuration.recentWallpaperPaths.insert(path, at: 0)
        configuration.recentWallpaperPaths = Array(configuration.recentWallpaperPaths.prefix(10))

        try save(configuration)
        return configuration
    }

    private func save(_ configuration: WallpaperConfiguration) throws {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(configuration)
        try data.write(to: AppPaths.configurationFile(), options: .atomic)
    }
}

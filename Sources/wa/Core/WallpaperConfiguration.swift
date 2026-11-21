import Foundation

struct WallpaperConfiguration: Codable, Equatable {
    static let recentLimit = 10

    var selectedWallpaperPath: String?
    var recentWallpaperPaths: [String]

    static let empty = WallpaperConfiguration(
        selectedWallpaperPath: nil,
        recentWallpaperPaths: []
    )

    /// Selects `path` and moves it to the front of the recent wallpapers.
    mutating func select(_ path: String) {
        selectedWallpaperPath = path
        recentWallpaperPaths.removeAll { $0 == path }
        recentWallpaperPaths.insert(path, at: 0)
        recentWallpaperPaths = Array(recentWallpaperPaths.prefix(Self.recentLimit))
    }
}

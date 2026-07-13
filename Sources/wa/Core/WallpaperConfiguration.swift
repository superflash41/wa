import Foundation

struct WallpaperConfiguration: Codable, Equatable {
    var selectedWallpaperPath: String?
    var recentWallpaperPaths: [String]

    static let empty = WallpaperConfiguration(
        selectedWallpaperPath: nil,
        recentWallpaperPaths: []
    )
}

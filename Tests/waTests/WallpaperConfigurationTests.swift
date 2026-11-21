import XCTest
@testable import wa

final class WallpaperConfigurationTests: XCTestCase {
    func testSelectMovesPathToFrontWithoutDuplicates() {
        var configuration = WallpaperConfiguration(
            selectedWallpaperPath: "/b.mp4",
            recentWallpaperPaths: ["/b.mp4", "/a.mp4", "/c.mp4"]
        )

        configuration.select("/a.mp4")

        XCTAssertEqual(configuration.selectedWallpaperPath, "/a.mp4")
        XCTAssertEqual(configuration.recentWallpaperPaths, ["/a.mp4", "/b.mp4", "/c.mp4"])
    }

    func testSelectKeepsOnlyTheMostRecentPaths() {
        var configuration = WallpaperConfiguration.empty

        for index in 0..<15 {
            configuration.select("/\(index).mp4")
        }

        XCTAssertEqual(configuration.recentWallpaperPaths.count, WallpaperConfiguration.recentLimit)
        XCTAssertEqual(configuration.recentWallpaperPaths.first, "/14.mp4")
        XCTAssertEqual(configuration.recentWallpaperPaths.last, "/5.mp4")
    }
}

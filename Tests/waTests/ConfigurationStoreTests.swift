import XCTest
@testable import wa

final class ConfigurationStoreTests: XCTestCase {
    private var directory: URL!
    private var fileURL: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("wa-tests-\(UUID().uuidString)", isDirectory: true)
        fileURL = directory.appendingPathComponent("config.json")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    func testLoadReturnsEmptyWhenFileIsMissing() {
        XCTAssertEqual(ConfigurationStore(fileURL: fileURL).load(), .empty)
    }

    func testSelectWallpaperPersistsSelection() throws {
        let video = URL(fileURLWithPath: "/videos/./loop.mp4")

        try ConfigurationStore(fileURL: fileURL).selectWallpaper(video)
        let loaded = ConfigurationStore(fileURL: fileURL).load()

        XCTAssertEqual(loaded.selectedWallpaperPath, "/videos/loop.mp4")
        XCTAssertEqual(loaded.recentWallpaperPaths, ["/videos/loop.mp4"])
    }

    func testUnreadableFileIsSetAsideInsteadOfOverwritten() throws {
        try AppPaths.createDirectory(directory)
        try Data("not json".utf8).write(to: fileURL)

        XCTAssertEqual(ConfigurationStore(fileURL: fileURL).load(), .empty)

        let backupURL = fileURL.appendingPathExtension("invalid")
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileURL.path))
        XCTAssertEqual(try String(contentsOf: backupURL, encoding: .utf8), "not json")
    }
}

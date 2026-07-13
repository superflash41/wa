import ArgumentParser
import Foundation

enum WallpaperFile {
    static func resolve(_ path: String) throws -> URL {
        let expandedPath = NSString(string: path).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath).standardizedFileURL

        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), !isDirectory.boolValue else {
            throw ValidationError("file does not exist: \(path)")
        }

        return url
    }

    static func resolveExecutable(_ path: String) throws -> URL {
        let url = try resolve(path)

        guard FileManager.default.isExecutableFile(atPath: url.path) else {
            throw ValidationError("file is not executable: \(path)")
        }

        return url
    }
}

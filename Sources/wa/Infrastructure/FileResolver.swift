import Foundation

enum FileResolverError: LocalizedError {
    case missingFile(String)
    case notExecutable(String)

    var errorDescription: String? {
        switch self {
        case let .missingFile(path):
            return "file does not exist: \(path)"
        case let .notExecutable(path):
            return "file is not executable: \(path)"
        }
    }
}

enum FileResolver {
    static func resolveFile(_ path: String) throws -> URL {
        let expandedPath = NSString(string: path).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath).standardizedFileURL

        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), !isDirectory.boolValue else {
            throw FileResolverError.missingFile(path)
        }

        return url
    }

    static func resolveExecutable(_ path: String) throws -> URL {
        let url = try resolveFile(path)

        guard FileManager.default.isExecutableFile(atPath: url.path) else {
            throw FileResolverError.notExecutable(path)
        }

        return url
    }
}

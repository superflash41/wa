import Foundation

enum PIDStore {
    static func runningPID() -> Int32? {
        guard let pid = storedPID(), kill(pid, 0) == 0 else {
            return nil
        }

        return pid
    }

    static func writeCurrentProcessID() throws {
        let pid = String(getpid())
        try AppPaths.createDirectory(AppPaths.applicationSupportDirectory)
        try pid.write(to: AppPaths.pidFile, atomically: true, encoding: .utf8)
    }

    static func remove() throws {
        let fileURL = AppPaths.pidFile
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    @discardableResult
    static func terminateRunningProcess() throws -> Bool {
        guard let pid = runningPID() else {
            try? remove()
            return false
        }

        guard kill(pid, SIGTERM) == 0 else {
            return false
        }

        try? remove()
        return true
    }

    private static func storedPID() -> Int32? {
        guard let contents = try? String(contentsOf: AppPaths.pidFile) else {
            return nil
        }

        return Int32(contents.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

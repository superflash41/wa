import Foundation

/// A pid together with its process start time. Pids are reused, so a stale
/// pid file must not be mistaken for a running wa.
struct ProcessRecord: Equatable {
    let pid: pid_t
    let startTime: UInt64

    init(pid: pid_t, startTime: UInt64) {
        self.pid = pid
        self.startTime = startTime
    }

    init?(contents: String) {
        let fields = contents.split(whereSeparator: \.isWhitespace)
        guard fields.count == 2, let pid = pid_t(fields[0]), let startTime = UInt64(fields[1]) else {
            return nil
        }

        self.init(pid: pid, startTime: startTime)
    }

    var contents: String {
        "\(pid) \(startTime)\n"
    }

    /// The record of a live process, or nil when no process has that pid.
    static func live(pid: pid_t) -> ProcessRecord? {
        var info = proc_bsdinfo()
        let size = Int32(MemoryLayout<proc_bsdinfo>.stride)
        guard proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &info, size) == size else {
            return nil
        }

        return ProcessRecord(pid: pid, startTime: info.pbi_start_tvsec * 1_000_000 + info.pbi_start_tvusec)
    }
}

enum PIDStore {
    /// The pid of the running wa app, when the pid file matches a live process.
    static func runningPID() -> pid_t? {
        guard let stored = storedRecord(), ProcessRecord.live(pid: stored.pid) == stored else {
            return nil
        }

        return stored.pid
    }

    static func writeCurrentProcess() throws {
        guard let record = ProcessRecord.live(pid: getpid()) else {
            throw POSIXError(.ESRCH)
        }

        try AppPaths.createDirectory(AppPaths.applicationSupportDirectory)
        try record.contents.write(to: AppPaths.pidFile, atomically: true, encoding: .utf8)
    }

    /// Removes the pid file only while it still names this process, so a slow
    /// shutdown never deletes the file of the instance that replaced it.
    static func removeIfOwned() {
        guard storedRecord()?.pid == getpid() else {
            return
        }

        try? FileManager.default.removeItem(at: AppPaths.pidFile)
    }

    /// Sends SIGTERM to the running app and waits up to `timeout` for it to exit.
    @discardableResult
    static func terminateRunningProcess(timeout: TimeInterval = 3) -> Bool {
        guard let pid = runningPID(), pid != getpid(), kill(pid, SIGTERM) == 0 else {
            return false
        }

        let deadline = Date().addingTimeInterval(timeout)
        while ProcessRecord.live(pid: pid) != nil, Date() < deadline {
            usleep(50_000)
        }

        return true
    }

    private static func storedRecord() -> ProcessRecord? {
        guard let contents = try? String(contentsOf: AppPaths.pidFile, encoding: .utf8) else {
            return nil
        }

        return ProcessRecord(contents: contents)
    }
}

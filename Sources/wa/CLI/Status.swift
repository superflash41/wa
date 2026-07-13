import ArgumentParser

struct Status: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Show wa process and LaunchAgent status."
    )

    mutating func run() throws {
        if let pid = PIDStore.runningPID() {
            print("wa is running (pid: \(pid))")
        } else {
            print("wa is not running")
        }

        let launchAgent = LaunchAgentManager()
        if launchAgent.isInstalled {
            print("always-on LaunchAgent is installed")
        } else {
            print("always-on LaunchAgent is not installed")
        }
    }
}

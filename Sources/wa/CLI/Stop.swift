import ArgumentParser

struct Stop: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Stop the running wa process."
    )

    mutating func run() throws {
        let launchAgent = LaunchAgentManager()
        let wasRunning = PIDStore.runningPID() != nil || launchAgent.runningPID != nil

        launchAgent.stop()
        PIDStore.terminateRunningProcess()

        print(wasRunning ? "stopped wa" : "wa is not running")

        if launchAgent.isInstalled {
            print("always-on LaunchAgent remains installed, so wa starts again at login. Run 'wa uninstall-agent' to remove it.")
        }
    }
}

import ArgumentParser

struct Stop: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Stop the running wa process."
    )

    mutating func run() throws {
        _ = try LaunchAgentManager().stop()

        if try PIDStore.terminateRunningProcess() {
            print("stopped wa")
        } else {
            print("wa is not running")
        }

        if LaunchAgentManager().isInstalled {
            print("always-on LaunchAgent remains installed. Run 'wa uninstall-agent' to remove it.")
        }
    }
}

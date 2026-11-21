import ArgumentParser

struct Status: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Show wa process and LaunchAgent status."
    )

    mutating func run() throws {
        let launchAgent = LaunchAgentManager()

        if let pid = PIDStore.runningPID() ?? launchAgent.runningPID {
            print("wa is running (pid: \(pid))")
        } else {
            print("wa is not running")
        }

        switch (launchAgent.isInstalled, launchAgent.isLoaded) {
        case (true, true):
            print("always-on LaunchAgent is installed and loaded")
        case (true, false):
            print("always-on LaunchAgent is installed but not loaded. It loads at login or with 'wa start'.")
        case (false, true):
            print("always-on LaunchAgent was removed and stays loaded until logout")
        case (false, false):
            print("always-on LaunchAgent is not installed")
        }
    }
}

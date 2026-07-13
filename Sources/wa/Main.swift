import ArgumentParser

@main
struct Wa: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "wa",
        abstract: "macOS live wallpaper manager",
        version: "0.2.0",
        subcommands: [
            Start.self,
            AppCommand.self,
            Daemon.self,
            Stop.self,
            Status.self,
            InstallAgent.self,
            UninstallAgent.self
        ],
        defaultSubcommand: Start.self
    )
}

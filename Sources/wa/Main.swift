import ArgumentParser

@main
struct Wa: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "wa",
        abstract: "macOS live wallpaper manager",
        version: "0.2.1",
        subcommands: [
            Start.self,
            AppCommand.self,
            Stop.self,
            Status.self,
            InstallAgent.self,
            UninstallAgent.self
        ],
        defaultSubcommand: Start.self
    )
}

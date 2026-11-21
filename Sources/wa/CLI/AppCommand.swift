import ArgumentParser

struct AppCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "app",
        abstract: "Run the foreground menu bar application.",
        // `daemon` was the command name before the menu bar app existed
        aliases: ["daemon"]
    )

    @Argument(help: "Path to a local video file.")
    var video: String?

    mutating func run() throws {
        try ApplicationRunner().run(videoPath: video)
    }
}

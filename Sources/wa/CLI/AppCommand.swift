import ArgumentParser

struct AppCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "app",
        abstract: "Run the foreground menu bar application."
    )

    @Argument(help: "Path to a local video file.")
    var video: String?

    mutating func run() throws {
        try ApplicationRunner().run(videoPath: video)
    }
}

struct Daemon: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Backward compatible alias for the menu bar app command."
    )

    @Argument(help: "Path to a local video file.")
    var video: String?

    mutating func run() throws {
        try ApplicationRunner().run(videoPath: video)
    }
}

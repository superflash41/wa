import os

enum Log {
    private static let subsystem = "local.wa.wallpaper-manager"

    static let playback = Logger(subsystem: subsystem, category: "playback")
    static let configuration = Logger(subsystem: subsystem, category: "configuration")
}

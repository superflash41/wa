import AVFoundation

/// Loops one video without a gap between iterations. A single instance feeds
/// every wallpaper window, so the file is decoded once for all displays.
final class LoopingPlayer {
    let player = AVQueuePlayer()
    private let looper: AVPlayerLooper
    private var statusObservation: NSKeyValueObservation?

    init(url: URL) {
        player.isMuted = true
        // avplayer holds a display sleep assertion while playing by default
        player.preventsDisplaySleepDuringVideoPlayback = false
        looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))

        statusObservation = looper.observe(\.status) { looper, _ in
            guard looper.status == .failed else {
                return
            }

            let reason = looper.error?.localizedDescription ?? "unknown error"
            Log.playback.error("cannot loop \(url.path, privacy: .public): \(reason, privacy: .public)")
        }
    }

    deinit {
        statusObservation?.invalidate()
        looper.disableLooping()
        player.pause()
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }
}

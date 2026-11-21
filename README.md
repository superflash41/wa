# wa

minimalist macOS menu bar app to loop a video as desktop wallpaper.

<p align="center">
  <img src="assets/demo.svg" width="760" alt="animated illustration of the wa menu bar menu: picking a wallpaper from recent wallpapers, then pausing and resuming playback">
</p>

## features

- loops a local video behind the desktop icons on every display, muted and without a gap between loops.
- decodes the video once for all displays and pauses while the desktop is fully covered.
- never keeps the display awake.
- menu bar menu to pick a video, switch between the last 10, pause, and turn always on on or off.
- optional launchagent that starts wa at login and restarts it after a crash.
- a small cli to start, stop and inspect wa from a terminal or a script.

## requirements

- macOS 12 or newer
- Swift 5.9 or newer (Xcode or the command line tools)
- [just](https://just.systems/) for the recipes below (optional)

## quick start

```bash
just run assets/kimi.mp4   # build, then start wa in the background with the sample video
just install               # optional: start at login and restart after a crash
```

then click the display icon in the menu bar to pick another video.

## menu bar

| item | what it does |
| --- | --- |
| `Current: <name>` | shows the video that is playing |
| `Select Wallpaper...` | picks any local video file |
| `Recent Wallpapers` | switches between the last 10 videos, the current one is checked |
| `Pause` / `Resume` | stops or continues playback and keeps the wallpaper on screen |
| `Refresh Displays` | rebuilds the wallpaper windows if a display looks wrong |
| `Enable Always On` / `Disable Always On` | installs or removes the launchagent. disabling keeps the current session running |
| `Quit wa` | quits. with always on enabled, wa stays quit until the next login |

## commands

the `wa` binary is both the cli and the app. `just build` puts a release build at `./wa`.

| command | what it does |
| --- | --- |
| `wa start [video]` | starts wa in the background, through the launchagent when it is installed. this is the default command |
| `wa app [video]` | runs the menu bar app in the foreground. `wa daemon` is an alias |
| `wa stop` | stops wa. an installed launchagent still starts it at the next login |
| `wa status` | shows whether wa is running and whether the launchagent is installed and loaded |
| `wa install-agent [video] [--executable <path>]` | installs the launchagent and starts it now |
| `wa uninstall-agent` | removes the launchagent and stops it |

the just recipes build first and then run the matching command:

| recipe | runs |
| --- | --- |
| `just run [video]` | `wa start [video]` |
| `just app [video]` | `wa app [video]` |
| `just stop` | `wa stop` |
| `just status` | `wa status` |
| `just install [video]` | `wa install-agent [video] --executable ./wa` |
| `just uninstall` | `wa uninstall-agent` |
| `just test` | `swift test` |
| `just clean` | removes `./wa` and `.build` |

## always on

`wa install-agent` writes a user launchagent at `~/Library/LaunchAgents/local.wa.wallpaper-manager.plist` that runs `wa app` in your login session (appkit needs a logged in aqua session). launchd starts it at login and restarts it only when it crashes, so `Quit wa` and `wa stop` stay in effect.

`just install` points the launchagent at `./wa` inside this repository. after `just clean` or moving the repository, run `just install` again from the new build.

upgrading from 0.2.0: run `just install` (or `wa install-agent`) once more so the plist picks up the crash only restart policy.

## files

| path | contents |
| --- | --- |
| `~/Library/Application Support/wa/config.json` | selected video and recent videos |
| `~/Library/Application Support/wa/wa.pid` | pid and start time of the running app |
| `~/Library/Application Support/wa/logs/` | launchagent stdout and stderr |
| `~/Library/LaunchAgents/local.wa.wallpaper-manager.plist` | the launchagent, while always on is enabled |

## troubleshooting

- follow wa's log with `log stream --predicate 'subsystem == "local.wa.wallpaper-manager"'`. it reports videos that cannot be played and config files that cannot be read.
- if the wallpaper does not appear after picking a video, avfoundation probably cannot decode it. the log above shows the reason. h.264 and hevc in `.mp4` or `.mov` work.
- `config.json.invalid` next to `config.json` means the config could not be read and was set aside. fix it by hand and rename it back, or delete it.
- crash reports land in `~/Library/Logs/DiagnosticReports/wa-*.ips`.

## development

```bash
swift build               # debug build
swift test                # unit tests
swift build -c release    # release build at .build/release/wa
.build/release/wa --help  # check the cli wiring
```

| directory | contents |
| --- | --- |
| `Sources/wa/App` | appkit: application runner, delegate and menu bar |
| `Sources/wa/CLI` | argument parser commands |
| `Sources/wa/Core` | playback: looping player, wallpaper windows and display handling |
| `Sources/wa/Infrastructure` | filesystem paths, configuration, launchagent, pid file and logging |
| `Tests/waTests` | unit tests |

## changelog

see [CHANGELOG.md](CHANGELOG.md).

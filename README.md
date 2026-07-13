# wa

minimalist macOS menu bar app to loop a video as desktop wallpaper.

## Requirements

- macOS 12 or newer
- Swift 5.9 or newer

## commands

supports [just](https://just.systems/):

```bash
# build the binary
just build

# start the menu bar app with a wallpaper
just run /path/to/video.mp4

# install the always-on LaunchAgent
just install /path/to/video.mp4

# stop wallpaper
just stop
```

## menu bar

after startup, `wa` appears in the macOS menu bar. from there you can:

- select a local video wallpaper.
- pick from recent wallpapers.
- pause or resume playback.
- refresh displays after monitor changes.
- enable or disable the always-on launchagent.

## cli

```bash
wa install [video]      # start at login and restart if the app exits
wa uninstall            # remove the launchagent
```

`install` writes a user launchagent at `~/Library/LaunchAgents/local.wa.wallpaper-manager.plist`.

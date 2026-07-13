# wa

minimalist macOS menu bar app to loop a video as desktop wallpaper.

## requirements

- macOS 12 or newer
- Swift 5.9 or newer

## commands

supports [just](https://just.systems/):

```bash
just install [video]      # start at login and restart if the app exits
just uninstall            # remove the launchagent
```

`install` writes a user launchagent at `~/Library/LaunchAgents/local.wa.wallpaper-manager.plist`.

<video src="./assets/kimi.mp4" controls></video>

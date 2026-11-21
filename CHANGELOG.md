# changelog

## 0.2.1 - 2026-11-21

reliability release for the menu bar app.

### fixed

- crash (`EXC_BAD_ACCESS` in `objc_release`) on display changes and wallpaper switches, caused by wallpaper windows being released twice.
- the display never went to sleep on its own while the wallpaper played, because avplayer held a display sleep assertion.
- `Quit wa` did not stay quit with always on enabled. the launchagent now restarts wa only after a crash. run `just install` again to update an existing plist.
- `Disable Always On` terminated the app it was clicked in when the launchagent was running that app.
- `wa stop`, `launchctl bootout` and ctrl-c killed the app without cleanup. sigterm and sigint now quit normally with exit status 0.
- a stale pid file could make `wa start` or `wa stop` signal an unrelated process that reused the pid.
- `wa stop` could print "wa is not running" right after stopping wa.
- display changes restarted the video and flashed the desktop.
- an unreadable `config.json` was silently replaced on the next selection. it is now kept as `config.json.invalid`.
- menu bar error alerts could open behind other windows.

### changed

- all displays share one gapless looping player instead of one player per display.
- `wa start` starts through the launchagent when it is installed.
- `wa status` shows whether the launchagent is loaded, not only whether it is installed.
- `Recent Wallpapers` marks the current wallpaper with a checkmark.
- playback and configuration problems are logged under the `local.wa.wallpaper-manager` subsystem.
- `wa daemon` is an alias of `wa app` instead of a separate command.
- swift-argument-parser 1.3.0 or newer is required.

### added

- unit tests, run with `swift test` or `just test`.
- an animated menu bar demo in the readme.

## 0.2.0 - 2026-07-13

- persistent menu bar app with wallpaper selection, recent wallpapers and the always on launchagent.

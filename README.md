# wa

A minimalist command-line tool for macOS that loops a local video as your desktop wallpaper.

## Usage

```bash
# compile
swiftc main.swift -o wa

# run
./wa /path/to/video.mp4
```

### Using Just

Supports [just](https://just.systems/):

```bash
# build the binary
just build

# build and run with a video
just run /path/to/video.mp4
```

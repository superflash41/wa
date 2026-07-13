# AGENTS.md

wa is a native macos live wallpaper manager.

## stack

- swift package manager for builds and dependency management.
- swift 5.9 or newer.
- macos 12 or newer.
- appkit for the menu bar app and wallpaper windows.
- avfoundation for video playback.
- swift argument parser for the cli.
- just for common local commands (check [justfile](justfile)).

## conventions

- keep project docs and user-facing repo text lowercase.
- use ascii text only.
- do not use emojis.
- avoid em dash, curly quotes, and typographic punctuation.
- keep appkit code in `sources/wa/app`.
- keep cli commands in `sources/wa/cli`.
- keep wallpaper playback logic in `sources/wa/core`.
- keep filesystem, launchagent, and process helpers in `sources/wa/infrastructure`.

## safety

- never execute destructive git commands directly without user approval.
- do not remove generated or user files unless the user asks.
- prefer launchagent for always-on behavior because appkit needs a logged-in aqua session.

## messages

- explain how changes can be tested or executed.
- name the exact commands to run.

## validation

- use `swift build` for quick compile checks.
- use `swift build -c release` before handoff when code changed.
- use `.build/release/wa --help` to verify cli command wiring.
- use `just --dry-run` when changing just recipes.
- do not run app-starting commands unless the user expects local app state to change.

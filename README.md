# MusicPlayer

[![release](https://img.shields.io/github/v/tag/ddddxxx/MusicPlayer?sort=semver)](https://github.com/ddddxxx/MusicPlayer/releases)
[![codebeat badge](https://codebeat.co/badges/1e88cb27-5d83-48d0-b50b-ad88593e2b5f)](https://codebeat.co/projects/github-com-ddddxxx-musicplayer-master)

Music player submodule for [LyricsX](https://github.com/ddddxxx/LyricsX).

Unified API for music players.

## Supported Players

#### macOS

- [x] Apple Music (iTunes)
- [x] Spotify
- [x] Vox
- [x] Audirvana
- [x] Swinsian

#### iOS

- [x] Music
- [ ] Spotify (see [#5](https://github.com/ddddxxx/MusicPlayer/issues/5))

#### Linux

- [x] [MPRIS](https://specifications.freedesktop.org/mpris-spec/latest/) (test needed) (Thanks to [@suransea](https://github.com/suransea))

##### dependencies

- [playerctl](https://github.com/altdesktop/playerctl) (could be installed by package manager)

#### Universal

- SystemMedia: System-wide Now Playing
  - [x] macOS
  - [x] iOS (jailbroken device only) (test needed)
  - [x] Linux (fake with MPRIS) (test needed)
- [ ] Spotify (Web API)

#### Helper:

- [x] Agent: Delegate events to another player.
- [x] Now Playing: Automatically choose a playing player from given players.
- [x] Virtual: A virtual player that allows you to manipulate its state.
- [ ] Remote: Sync player state from other devices.

## Usage

### Quick Start

```swift
let player = MusicPlayers.Scriptable(name: .appleMusic)!
let track = player.currentTrack.title
if player.playbackState.isPlaying {
    player.skipToNextItem()
}
```

## License

MusicPlayer is part of LyricsX and licensed under MPL 2.0. See the [LICENSE file](LICENSE).

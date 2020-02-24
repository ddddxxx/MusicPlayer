# MusicPlayer

[![release](https://img.shields.io/github/v/tag/ddddxxx/MusicPlayer?sort=semver)](https://github.com/ddddxxx/MusicPlayer/releases)
[![codebeat badge](https://codebeat.co/badges/1e88cb27-5d83-48d0-b50b-ad88593e2b5f)](https://codebeat.co/projects/github-com-ddddxxx-musicplayer-master)

Music player submodule for [LyricsX](https://github.com/ddddxxx/LyricsX).

Unified API for music players.

## Supported Player

#### macOS

- [x] System-wide Now Playing
- [x] Apple Music (iTunes)
- [x] Spotify
- [x] Vox
- [x] Audirvana
- [x] Swinsian

#### iOS

- [x] Music
- [ ] Spotify (blocked by SE-0272)

#### Linux

- [ ] [MPRIS](https://specifications.freedesktop.org/mpris-spec/latest/)

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

MusicPlayer is part of LyricsX and licensed under GPLv3. See the [LICENSE file](https://github.com/ddddxxx/LyricsX/blob/master/LICENSE) of LyricsX.

Additionally, LXMusicPlayer is available under LGPLv3. See the [LICENSE file](Sources/LXMusicPlayer/LICENSE).

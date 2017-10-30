import Cocoa
import PlaygroundSupport
import MusicPlayer

PlaygroundPage.current.needsIndefiniteExecution = true

extension MusicPlayer {
    
    public var name: MusicPlayerName {
        return type(of: self).name
    }
}

class MusicPlayerManagerObserver: MusicPlayerManagerDelegate {

    func runningStateChanged(isRunning: Bool) {
        print("is running: \(isRunning)")
    }

    func currentPlayerChanged(player: MusicPlayer?) {
        print("player name: \(player?.name.rawValue ?? "no player")")
    }

    func currentTrackChanged(track: MusicTrack?) {
        print("track: \(track?.title ?? "no title")")
    }

    func playbackStateChanged(state: MusicPlaybackState) {
        print("state: \(state)")
    }

    func playerPositionMutated(position: TimeInterval) {
        print("position: \(position)")
    }
}

MusicPlayerManager.shared.delegate = MusicPlayerManagerObserver()
MusicPlayerManager.shared.player

//PlaygroundPage.current.finishExecution()


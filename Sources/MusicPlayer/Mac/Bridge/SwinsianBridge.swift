//
//  SwinsianBridge.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017 Xander Deng - https://github.com/ddddxxx/LyricsX
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#if os(macOS)

import AppKit
import ScriptingBridge


@objc enum SwinsianSaveOptions: AEKeyword {
    case yes = 0x79657320 /* Save the file. */
    case no = 0x6e6f2020 /* Do not save the file. */
    case ask = 0x61736b20 /* Ask the user whether or not to save the file. */
};
@objc enum SwinsianPlayerState: AEKeyword {
    case stopped = 0x6b505353
    case playing = 0x6b505350
    case paused = 0x6b505370
};

@objc protocol SwinsianGenericMethods {
    @objc optional func closeSaving(saving: SwinsianSaveOptions, savingIn: URL)
    // Close an object.
    @objc optional func delete()
    // Delete an object.
    @objc optional func duplicateTo(to: SBObject, withProperties: NSDictionary)
    // Copy object(s) and put the copies at a new location.
    @objc optional func exists() -> Bool
    // Verify if an object exists.
    @objc optional func moveTo(to: SBObject)
    // Move object(s) to a new location.
    @objc optional func saveIn(`in`: URL, `as`: String)
    // Save an object.
}


/*
 * Standard Suite
 */
// A scriptable object.
@objc protocol SwinsianItem {
    @objc optional var properties: NSDictionary? {get set}
    // All of the object"s properties.
}
extension SBObject: SwinsianItem{}


// A color.
@objc protocol SwinsianColor {}
extension SBObject: SwinsianColor{}


// A window.
@objc protocol SwinsianWindow {
    @objc optional var name: String? {get set}
    // The full title of the window.
    @objc optional func id() -> NSNumber?
    // The unique identifier of the window.
    @objc optional var bounds: NSRect {get set}
    // The bounding rectangle of the window.
    @objc optional var closeable: Bool {get}
    // Whether the window has a close box.
    @objc optional var titled: Bool {get}
    // Whether the window has a title bar.
    @objc optional var index: NSNumber? {get set}
    // The index of the window in the back-to-front window ordering.
    @objc optional var floating: Bool {get}
    // Whether the window floats.
    @objc optional var miniaturizable: Bool {get}
    // Whether the window can be miniaturized.
    @objc optional var miniaturized: Bool {get set}
    // Whether the window is currently miniaturized.
    @objc optional var modal: Bool {get}
    // Whether the window is the application"s current modal window.
    @objc optional var resizable: Bool {get}
    // Whether the window can be resized.
    @objc optional var visible: Bool {get set}
    // Whether the window is currently visible.
    @objc optional var zoomable: Bool {get}
    // Whether the window can be zoomed.
    @objc optional var zoomed: Bool {get set}
    // Whether the window is currently zoomed.
    @objc optional var selection: [SwinsianTrack] {get}
    // Currently seleted tracks
}
extension SBObject: SwinsianWindow{}


/*
 * Swinsian Suite
 */
// The application
@objc protocol SwinsianApplication {
    @objc optional func windows() -> [SwinsianWindow]
    @objc optional func playlists() -> [SwinsianPlaylist]
    @objc optional func smartPlaylists() -> [SwinsianSmartPlaylist]
    @objc optional func normalPlaylists() -> [SwinsianNormalPlaylist]
    @objc optional func libraries() -> [SwinsianLibrary]
    @objc optional func tracks() -> [SwinsianTrack]
    @objc optional func audioDevices() -> [SwinsianAudioDevice]
    @objc optional var name: String? {get}
    // The name of the application.
    @objc optional var frontmost: Bool {get}
    // Is this the frontmost (active) application?
    @objc optional var version: String? {get}
    // The version of the application.
    @objc optional var playerPosition: Int {get set}
    // the player’s position within the currently playing track in seconds.
    @objc optional var currentTrack: SwinsianTrack? {get}
    // the currently playing track
    @objc optional var soundVolume: NSNumber? {get set}
    // the volume. (0 minimum, 100 maximum)
    @objc optional var playerState: SwinsianPlayerState {get}
    // are we stopped, paused or still playing?
    @objc optional var playbackQueue: SwinsianQueue? {get}
    // the currently queued tracks
    @objc optional var outputDevice: SwinsianAudioDevice? {get set}
    // current audio output device
    @objc optional func open(x: URL)
    // Open an object.
    @objc optional func print(x: URL)
    // Print an object.
    @objc optional func quitSaving(saving: SwinsianSaveOptions)
    // Quit an application.
    @objc optional func play()
    // begin playing the current playlist
    @objc optional func pause()
    // pause playback
    @objc optional func nextTrack()
    // skip to the next track in the current playlist
    @objc optional func stop()
    // stop playback
    @objc optional func searchPlaylist(playlist: SwinsianPlaylist, `for`: String) -> [SwinsianTrack]
    // search a playlist for tracks matching a string
    @objc optional func previousTrack()
    // skip back to the previous track
    @objc optional func playpause()
    // toggle play/pause
    @objc optional func addTracks(tracks: [SwinsianTrack], to: SwinsianNormalPlaylist)
    // add a track to a playlist
    @objc optional func notify()
    // show currently playing track notification
    @objc optional func rescanTags(x: [SwinsianTrack])
    // rescan tags on tracks
    @objc optional func findTrack(x: String) -> [SwinsianTrack]
    // Finds tracks for the given path
    @objc optional func removeTracks(tracks: [SwinsianTrack], from: SwinsianNormalPlaylist)
    // remove tracks from a playlist
}
extension SBApplication: SwinsianApplication{}


// generic playlist type, subcasses include smart playlist and normal playlist
@objc protocol SwinsianPlaylist: SwinsianItem {
    @objc optional func tracks() -> [SwinsianTrack]
    @objc optional var name: String? {get set}
    // the name of the playlist
    @objc optional var smart: Bool {get}
    // is this a smart playlist
}
extension SBObject: SwinsianPlaylist{}


@objc protocol SwinsianLibrary: SwinsianItem {
    @objc optional func tracks() -> [SwinsianTrack]
}
extension SBObject: SwinsianLibrary{}


// a music track
@objc protocol SwinsianTrack: SwinsianItem {
    @objc optional var album: String? {get set}
    // the album of the track
    @objc optional var artist: String? {get set}
    // the artist
    @objc optional var composer: String? {get set}
    // the composer
    @objc optional var genre: String? {get set}
    // the genre
    @objc optional var time: String? {get}
    // the length of the track in text format as MM:SS
    @objc optional var year: Int {get set}
    // the year the track was recorded
    @objc optional var dateAdded: Date {get}
    // the date the track was added to the library
    @objc optional var duration: Double {get}
    // the length of the track in seconds
    @objc optional var location: String? {get}
    // location on disk
    @objc optional var iPodTrack: Bool {get}
    // TRUE if the track is on an iPod
    @objc optional var name: String? {get set}
    // the title of the track (same as title)
    @objc optional var bitRate: Int {get}
    // the bitrate of the track
    @objc optional var kind: String? {get}
    // a text description of the type of file the track is
    @objc optional var rating: NSNumber? {get set}
    // Track rating. 0-5
    @objc optional var trackNumber: Int {get set}
    // the Track number
    @objc optional var fileSize: Int {get}
    // file size in bytes
    @objc optional var albumArt: NSImage? {get}
    // the album artwork
    @objc optional var artFormat: String? {get}
    // the data format for this piece of artwork. text that will be "PNG" or "JPEG". getting the album art property first will mean this information has been retrieved already, otherwise the tags for the file will have to be re-read
    @objc optional var discNumber: NSNumber? {get set}
    // the disc number
    @objc optional var discCount: NSNumber? {get set}
    // the total number of discs in the album
    @objc optional func id() -> String?
    // uuid
    @objc optional var albumArtist: String? {get set}
    // the album artist
    @objc optional var albumArtistOrArtist: String? {get}
    // the album artist of the track, or is none is set, the artist
    @objc optional var compilation: Bool {get set}
    // compilation flag
    @objc optional var title: String? {get set}
    // track title (the same as name)
    @objc optional var comment: String? {get set}
    // the comment
    @objc optional var dateCreated: Date {get}
    // the date created
    @objc optional var channels: Int {get}
    // audio channel count
    @objc optional var sampleRate: Int {get}
    // audio sample rate
    @objc optional var bitDepth: Int {get}
    // the audio bit depth
    @objc optional var lastPlayed: Date {get set}
    // date track was last played
    @objc optional var lyrics: String? {get set}
    // track lyrics
    @objc optional var path: String? {get}
    // POSIX style path
    @objc optional var grouping: String? {get set}
    // grouping
    @objc optional var publisher: String? {get set}
    // the publisher
    @objc optional var conductor: String? {get set}
    // the conductor
    @objc optional var objectDescription: String? {get set}
    // the description
    @objc optional var encoder: String? {get}
    // the encoder
    @objc optional var copyright: String? {get}
    // the copyright
    @objc optional var catalogNumber: String? {get set}
    // the catalog number
    @objc optional var dateModified: Date {get}
    // the date modified
    @objc optional var playCount: Int {get set}
    // the play count
    @objc optional var trackCount: NSNumber? {get set}
    // the total number of tracks in the album
}
extension SBObject: SwinsianTrack{}


@objc protocol SwinsianLibraryTrack: SwinsianTrack {}
extension SBObject: SwinsianLibraryTrack{}


@objc protocol SwinsianIPodTrack: SwinsianTrack {
    @objc optional var iPodName: String? {get}
    // the name of the iPod this track is on
}
extension SBObject: SwinsianIPodTrack{}


// The playback queue
@objc protocol SwinsianQueue: SwinsianItem {
    @objc optional func tracks() -> [SwinsianTrack]
}
extension SBObject: SwinsianQueue{}


// a smart playlist
@objc protocol SwinsianSmartPlaylist: SwinsianPlaylist {}
extension SBObject: SwinsianSmartPlaylist{}


// a normal, non-smart, playlist
@objc protocol SwinsianNormalPlaylist: SwinsianPlaylist {
    @objc optional func tracks() -> [SwinsianTrack]
    @objc optional func id() -> String?
    // uuid
}
extension SBObject: SwinsianNormalPlaylist{}


// folder of playlists
@objc protocol SwinsianPlaylistFolder: SwinsianPlaylist {
    @objc optional func playlists() -> [SwinsianPlaylist]
    @objc optional func id() -> String?
    // uuid
}
extension SBObject: SwinsianPlaylistFolder{}


// an audio output device
@objc protocol SwinsianAudioDevice {
    @objc optional var name: String? {get}
    // device name
    @objc optional func id() -> String?
    // uuid
    @objc optional func setId(id: String)
}
extension SBObject: SwinsianAudioDevice{}

#endif

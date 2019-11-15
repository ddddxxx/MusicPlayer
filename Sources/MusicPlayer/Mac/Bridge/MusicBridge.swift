//
//  MusicBridge.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

#if os(macOS)

import AppKit
import ScriptingBridge


@objc enum MusicEKnd: AEKeyword {
    case trackListing = 0x6b54726b /* a basic listing of tracks within a playlist */
    case albumListing = 0x6b416c62 /* a listing of a playlist grouped by album */
    case cdInsert = 0x6b434469 /* a printout of the playlist for jewel case inserts */
}


@objc enum MusicEnum: AEKeyword {
    case standard = 0x6c777374 /* Standard PostScript error handling */
    case detailed = 0x6c776474 /* print a detailed report of PostScript errors */
}


@objc enum MusicEPlS: AEKeyword {
    case stopped = 0x6b505353
    case playing = 0x6b505350
    case paused = 0x6b505370
    case fastForwarding = 0x6b505346
    case rewinding = 0x6b505352
}


@objc enum MusicERpt: AEKeyword {
    case off = 0x6b52704f
    case one = 0x6b527031
    case all = 0x6b416c6c
}


@objc enum MusicEShM: AEKeyword {
    case songs = 0x6b536853
    case albums = 0x6b536841
    case groupings = 0x6b536847
}


@objc enum MusicESrc: AEKeyword {
    case library = 0x6b4c6962
    case iPod = 0x6b506f64
    case audioCD = 0x6b414344
    case mp3CD = 0x6b4d4344
    case radioTuner = 0x6b54756e
    case sharedLibrary = 0x6b536864
    case iTunesStore = 0x6b495453
    case unknown = 0x6b556e6b
}


@objc enum MusicESrA: AEKeyword {
    case albums = 0x6b53724c /* albums only */
    case all = 0x6b416c6c /* all text fields */
    case artists = 0x6b537252 /* artists only */
    case composers = 0x6b537243 /* composers only */
    case displayed = 0x6b537256 /* visible text fields */
    case songs = 0x6b537253 /* song names only */
}


@objc enum MusicESpK: AEKeyword {
    case none = 0x6b4e6f6e
    case folder = 0x6b537046
    case genius = 0x6b537047
    case library = 0x6b53704c
    case music = 0x6b53705a
    case purchasedMusic = 0x6b53704d
}


@objc enum MusicEMdK: AEKeyword {
    case song = 0x6b4d6453 /* music track */
    case musicVideo = 0x6b566456 /* music video track */
    case unknown = 0x6b556e6b
}


@objc enum MusicERtK: AEKeyword {
    case user = 0x6b527455 /* user-specified rating */
    case computed = 0x6b527443 /* iTunes-computed rating */
}


@objc enum MusicEAPD: AEKeyword {
    case computer = 0x6b415043
    case airPortExpress = 0x6b415058
    case appleTV = 0x6b415054
    case airPlayDevice = 0x6b41504f
    case bluetoothDevice = 0x6b415042
    case homePod = 0x6b415048
    case unknown = 0x6b415055
}


@objc enum MusicEClS: AEKeyword {
    case unknown = 0x6b556e6b
    case purchased = 0x6b507572
    case matched = 0x6b4d6174
    case uploaded = 0x6b55706c
    case ineligible = 0x6b52656a
    case removed = 0x6b52656d
    case error = 0x6b457272
    case duplicate = 0x6b447570
    case subscription = 0x6b537562
    case noLongerAvailable = 0x6b526576
    case notUploaded = 0x6b557050
}


@objc protocol MusicGenericMethods {
    @objc optional func printPrintDialog(printDialog: Bool, withProperties: [String: Any], kind: MusicEKnd, theme: String!)
    // Print the specified object(s)
    @objc optional func close()
    // Close an object
    @objc optional func delete()
    // Delete an element from an object
    @objc optional func duplicateTo(to: SBObject) -> SBObject
    // Duplicate one or more object(s)
    @objc optional func exists() -> Bool
    // Verify if an object exists
    @objc optional func open()
    // Open the specified object(s)
    @objc optional func save()
    // Save the specified object(s)
    @objc optional func playOnce(once: Bool)
    // play the current track or the specified track or file.
    @objc optional func select()
    // select the specified object(s)
}


/*
 * iTunes Suite
 */
// The application program
@objc protocol MusicApplication {
    @objc optional func AirPlayDevices() -> [MusicAirPlayDevice]
    @objc optional func browserWindows() -> [MusicBrowserWindow]
    @objc optional func encoders() -> [MusicEncoder]
    @objc optional func EQPresets() -> [MusicEQPreset]
    @objc optional func EQWindows() -> [MusicEQWindow]
    @objc optional func miniplayerWindows() -> [MusicMiniplayerWindow]
    @objc optional func playlists() -> [MusicPlaylist]
    @objc optional func playlistWindows() -> [MusicPlaylistWindow]
    @objc optional func sources() -> [MusicSource]
    @objc optional func tracks() -> [SBMusicTrack]
    @objc optional func videoWindows() -> [MusicVideoWindow]
    @objc optional func visuals() -> [MusicVisual]
    @objc optional func windows() -> [MusicWindow]
    @objc optional var AirPlayEnabled: Bool {get}
    // is AirPlay currently enabled?
    @objc optional var converting: Bool {get}
    // is a track currently being converted?
    @objc optional var currentAirPlayDevices: [MusicAirPlayDevice] {get set}
    // the currently selected AirPlay device(s)
    @objc optional var currentEncoder: MusicEncoder {get set}
    // the currently selected encoder (MP3, AIFF, WAV, etc.)
    @objc optional var currentEQPreset: MusicEQPreset {get set}
    // the currently selected equalizer preset
    @objc optional var currentPlaylist: MusicPlaylist {get}
    // the playlist containing the currently targeted track
    @objc optional var currentStreamTitle: String? {get}
    // the name of the current song in the playing stream (provided by streaming server)
    @objc optional var currentStreamURL: String? {get}
    // the URL of the playing stream or streaming web site (provided by streaming server)
    @objc optional var currentTrack: SBMusicTrack {get}
    // the current targeted track
    @objc optional var currentVisual: MusicVisual {get set}
    // the currently selected visual plug-in
    @objc optional var EQEnabled: Bool {get set}
    // is the equalizer enabled?
    @objc optional var fixedIndexing: Bool {get set}
    // true if all AppleScript track indices should be independent of the play order of the owning playlist.
    @objc optional var frontmost: Bool {get set}
    // is iTunes the frontmost application?
    @objc optional var fullScreen: Bool {get set}
    // are visuals displayed using the entire screen?
    @objc optional var name: String? {get}
    // the name of the application
    @objc optional var mute: Bool {get set}
    // has the sound output been muted?
    @objc optional var playerPosition: Double {get set}
    // the player’s position within the currently playing track in seconds.
    @objc optional var playerState: MusicEPlS {get}
    // is iTunes stopped, paused, or playing?
    @objc optional var selection: SBObject {get}
    // the selection visible to the user
    @objc optional var shuffleEnabled: Bool {get set}
    // are songs played in random order?
    @objc optional var shuffleMode: MusicEShM {get set}
    // the playback shuffle mode
    @objc optional var songRepeat: MusicERpt {get set}
    // the playback repeat mode
    @objc optional var soundVolume: Int {get set}
    // the sound output volume (0 = minimum, 100 = maximum)
    @objc optional var version: String? {get}
    // the version of iTunes
    @objc optional var visualsEnabled: Bool {get set}
    // are visuals currently being displayed?
    @objc optional func printPrintDialog(printDialog: Bool, withProperties: [String: Any], kind: MusicEKnd, theme: String!)
    // Print the specified object(s)
    @objc optional func run()
    // Run iTunes
    @objc optional func quit()
    // Quit iTunes
    @objc optional func add(x: [URL], to: SBObject) -> SBMusicTrack
    // add one or more files to a playlist
    @objc optional func backTrack()
    // reposition to beginning of current track or go to previous track if already at start of current track
    @objc optional func convert(x: [Any]) -> SBMusicTrack
    // convert one or more files or tracks
    @objc optional func fastForward()
    // skip forward in a playing track
    @objc optional func nextTrack()
    // advance to the next track in the current playlist
    @objc optional func pause()
    // pause playback
    @objc optional func playOnce(once: Bool)
    // play the current track or the specified track or file.
    @objc optional func playpause()
    // toggle the playing/paused state of the current track
    @objc optional func previousTrack()
    // return to the previous track in the current playlist
    @objc optional func resume()
    // disable fast forward/rewind and resume playback, if playing.
    @objc optional func rewind()
    // skip backwards in a playing track
    @objc optional func stop()
    // stop playback
    @objc optional func openLocation(x: String!)
    // Opens a Music Store or audio stream URL
}
extension SBApplication: MusicApplication{}


// an item
@objc protocol MusicItem {
    @objc optional var container: SBObject {get}
    // the container of the item
    @objc optional func id() -> Int
    // the id of the item
    @objc optional var index: Int {get}
    // The index of the item in internal application order.
    @objc optional var name: String? {get set}
    // the name of the item
    @objc optional var persistentID: String? {get}
    // the id of the item as a hexadecimal string. This id does not change over time.
    @objc optional var properties: [String: Any]? {get set}
    // every property of the item
    @objc optional func download()
    // download a cloud track or playlist
    @objc optional func reveal()
    // reveal and select a track or playlist
}
extension SBObject: MusicItem{}


// an AirPlay device
@objc protocol MusicAirPlayDevice: MusicItem {
    @objc optional var active: Bool {get}
    // is the device currently being played to?
    @objc optional var available: Bool {get}
    // is the device currently available?
    @objc optional var kind: MusicEAPD {get}
    // the kind of the device
    @objc optional var networkAddress: String? {get}
    // the network (MAC) address of the device
    @objc optional func protected() -> Bool
    // is the device password- or passcode-protected?
    @objc optional var selected: Bool {get set}
    // is the device currently selected?
    @objc optional var supportsAudio: Bool {get}
    // does the device support audio playback?
    @objc optional var supportsVideo: Bool {get}
    // does the device support video playback?
    @objc optional var soundVolume: Int {get set}
    // the output volume for the device (0 = minimum, 100 = maximum)
}
extension SBObject: MusicAirPlayDevice{}


// a piece of art within a track or playlist
@objc protocol MusicArtwork: MusicItem {
    @objc optional var data: NSImage? {get set}
    // data for this artwork, in the form of a picture
    @objc optional var objectDescription: String? {get set}
    // description of artwork as a string
    @objc optional var downloaded: Bool {get}
    // was this artwork downloaded by iTunes?
    @objc optional var format: NSNumber? {get}
    // the data format for this piece of artwork
    @objc optional var kind: Int {get set}
    // kind or purpose of this piece of artwork
    @objc optional var rawData: Data? {get set}
    // data for this artwork, in original format
}
extension SBObject: MusicArtwork{}


// converts a track to a specific file format
@objc protocol MusicEncoder: MusicItem {
    @objc optional var format: String? {get}
    // the data format created by the encoder
}
extension SBObject: MusicEncoder{}


// equalizer preset configuration
@objc protocol MusicEQPreset: MusicItem {
    @objc optional var band1: Double {get set}
    // the equalizer 32 Hz band level (-12.0 dB to +12.0 dB)
    @objc optional var band2: Double {get set}
    // the equalizer 64 Hz band level (-12.0 dB to +12.0 dB)
    @objc optional var band3: Double {get set}
    // the equalizer 125 Hz band level (-12.0 dB to +12.0 dB)
    @objc optional var band4: Double {get set}
    // the equalizer 250 Hz band level (-12.0 dB to +12.0 dB)
    @objc optional var band5: Double {get set}
    // the equalizer 500 Hz band level (-12.0 dB to +12.0 dB)
    @objc optional var band6: Double {get set}
    // the equalizer 1 kHz band level (-12.0 dB to +12.0 dB)
    @objc optional var band7: Double {get set}
    // the equalizer 2 kHz band level (-12.0 dB to +12.0 dB)
    @objc optional var band8: Double {get set}
    // the equalizer 4 kHz band level (-12.0 dB to +12.0 dB)
    @objc optional var band9: Double {get set}
    // the equalizer 8 kHz band level (-12.0 dB to +12.0 dB)
    @objc optional var band10: Double {get set}
    // the equalizer 16 kHz band level (-12.0 dB to +12.0 dB)
    @objc optional var modifiable: Bool {get}
    // can this preset be modified?
    @objc optional var preamp: Double {get set}
    // the equalizer preamp level (-12.0 dB to +12.0 dB)
    @objc optional var updateTracks: Bool {get set}
    // should tracks which refer to this preset be updated when the preset is renamed or deleted?
}
extension SBObject: MusicEQPreset{}


// a list of songs/streams
@objc protocol MusicPlaylist: MusicItem {
    @objc optional func tracks() -> [SBMusicTrack]
    @objc optional func artworks() -> [MusicArtwork]
    @objc optional var objectDescription: String? {get set}
    // the description of the playlist
    @objc optional var disliked: Bool {get set}
    // is this playlist disliked?
    @objc optional var duration: Int {get}
    // the total length of all songs (in seconds)
    @objc optional var name: String? {get set}
    // the name of the playlist
    @objc optional var loved: Bool {get set}
    // is this playlist loved?
    @objc optional var parent: MusicPlaylist {get}
    // folder which contains this playlist (if any)
    @objc optional var size: Int {get}
    // the total size of all songs (in bytes)
    @objc optional var specialKind: MusicESpK {get}
    // special playlist kind
    @objc optional var time: String? {get}
    // the length of all songs in MM:SS format
    @objc optional var visible: Bool {get}
    // is this playlist visible in the Source list?
    @objc optional func moveTo(to: SBObject)
    // Move playlist(s) to a new location
    @objc optional func searchFor(`for`: String!, only: MusicESrA) -> SBMusicTrack
    // search a playlist for tracks matching the search string. Identical to entering search text in the Search field in iTunes.
}
extension SBObject: MusicPlaylist{}


// a playlist representing an audio CD
@objc protocol MusicAudioCDPlaylist: MusicPlaylist {
    @objc optional func audioCDTracks() -> [MusicAudioCDTrack]
    @objc optional var artist: String? {get set}
    // the artist of the CD
    @objc optional var compilation: Bool {get set}
    // is this CD a compilation album?
    @objc optional var composer: String? {get set}
    // the composer of the CD
    @objc optional var discCount: Int {get set}
    // the total number of discs in this CD’s album
    @objc optional var discNumber: Int {get set}
    // the index of this CD disc in the source album
    @objc optional var genre: String? {get set}
    // the genre of the CD
    @objc optional var year: Int {get set}
    // the year the album was recorded/released
}
extension SBObject: MusicAudioCDPlaylist{}


// the master music library playlist
@objc protocol MusicLibraryPlaylist: MusicPlaylist {
    @objc optional func fileTracks() -> [MusicFileTrack]
    @objc optional func URLTracks() -> [MusicURLTrack]
    @objc optional func sharedTracks() -> [MusicSharedTrack]
}
extension SBObject: MusicLibraryPlaylist{}


// the radio tuner playlist
@objc protocol MusicRadioTunerPlaylist: MusicPlaylist {
    @objc optional func URLTracks() -> [MusicURLTrack]
}
extension SBObject: MusicRadioTunerPlaylist{}


// a music source (music library, CD, device, etc.)
@objc protocol MusicSource: MusicItem {
    @objc optional func audioCDPlaylists() -> [MusicAudioCDPlaylist]
    @objc optional func libraryPlaylists() -> [MusicLibraryPlaylist]
    @objc optional func playlists() -> [MusicPlaylist]
    @objc optional func radioTunerPlaylists() -> [MusicRadioTunerPlaylist]
    @objc optional func subscriptionPlaylists() -> [MusicSubscriptionPlaylist]
    @objc optional func userPlaylists() -> [MusicUserPlaylist]
    @objc optional var capacity: CLong {get}
    // the total size of the source if it has a fixed size
    @objc optional var freeSpace: CLong {get}
    // the free space on the source if it has a fixed size
    @objc optional var kind: MusicESrc {get}
}
extension SBObject: MusicSource{}


// a subscription playlist from Apple Music
@objc protocol MusicSubscriptionPlaylist: MusicPlaylist {
    @objc optional func fileTracks() -> [MusicFileTrack]
    @objc optional func URLTracks() -> [MusicURLTrack]
}
extension SBObject: MusicSubscriptionPlaylist{}


// playable audio source
@objc(MusicTrack) protocol SBMusicTrack: MusicItem {
    @objc optional func artworks() -> [MusicArtwork]
    @objc optional var album: String? {get set}
    // the album name of the track
    @objc optional var albumArtist: String? {get set}
    // the album artist of the track
    @objc optional var albumDisliked: Bool {get set}
    // is the album for this track disliked?
    @objc optional var albumLoved: Bool {get set}
    // is the album for this track loved?
    @objc optional var albumRating: Int {get set}
    // the rating of the album for this track (0 to 100)
    @objc optional var albumRatingKind: MusicERtK {get}
    // the rating kind of the album rating for this track
    @objc optional var artist: String? {get set}
    // the artist/source of the track
    @objc optional var bitRate: Int {get}
    // the bit rate of the track (in kbps)
    @objc optional var bookmark: Double {get set}
    // the bookmark time of the track in seconds
    @objc optional var bookmarkable: Bool {get set}
    // is the playback position for this track remembered?
    @objc optional var bpm: Int {get set}
    // the tempo of this track in beats per minute
    @objc optional var category: String? {get set}
    // the category of the track
    @objc optional var cloudStatus: MusicEClS {get}
    // the iCloud status of the track
    @objc optional var comment: String? {get set}
    // freeform notes about the track
    @objc optional var compilation: Bool {get set}
    // is this track from a compilation album?
    @objc optional var composer: String? {get set}
    // the composer of the track
    @objc optional var databaseID: Int {get}
    // the common, unique ID for this track. If two tracks in different playlists have the same database ID, they are sharing the same data.
    @objc optional var dateAdded: Date {get}
    // the date the track was added to the playlist
    @objc optional var objectDescription: String? {get set}
    // the description of the track
    @objc optional var discCount: Int {get set}
    // the total number of discs in the source album
    @objc optional var discNumber: Int {get set}
    // the index of the disc containing this track on the source album
    @objc optional var disliked: Bool {get set}
    // is this track disliked?
    @objc optional var downloaderAppleID: String? {get}
    // the Apple ID of the person who downloaded this track
    @objc optional var downloaderName: String? {get}
    // the name of the person who downloaded this track
    @objc optional var duration: Double {get}
    // the length of the track in seconds
    @objc optional var enabled: Bool {get set}
    // is this track checked for playback?
    @objc optional var episodeID: String? {get set}
    // the episode ID of the track
    @objc optional var episodeNumber: Int {get set}
    // the episode number of the track
    @objc optional var EQ: String? {get set}
    // the name of the EQ preset of the track
    @objc optional var finish: Double {get set}
    // the stop time of the track in seconds
    @objc optional var gapless: Bool {get set}
    // is this track from a gapless album?
    @objc optional var genre: String? {get set}
    // the music/audio genre (category) of the track
    @objc optional var grouping: String? {get set}
    // the grouping (piece) of the track. Generally used to denote movements within a classical work.
    @objc optional var kind: String? {get}
    // a text description of the track
    @objc optional var longDescription: String? {get set}
    @objc optional var loved: Bool {get set}
    // is this track loved?
    @objc optional var lyrics: String? {get set}
    // the lyrics of the track
    @objc optional var mediaKind: MusicEMdK {get set}
    // the media kind of the track
    @objc optional var modificationDate: Date {get}
    // the modification date of the content of this track
    @objc optional var movement: String? {get set}
    // the movement name of the track
    @objc optional var movementCount: Int {get set}
    // the total number of movements in the work
    @objc optional var movementNumber: Int {get set}
    // the index of the movement in the work
    @objc optional var playedCount: Int {get set}
    // number of times this track has been played
    @objc optional var playedDate: Date {get set}
    // the date and time this track was last played
    @objc optional var purchaserAppleID: String? {get}
    // the Apple ID of the person who purchased this track
    @objc optional var purchaserName: String? {get}
    // the name of the person who purchased this track
    @objc optional var rating: Int {get set}
    // the rating of this track (0 to 100)
    @objc optional var ratingKind: MusicERtK {get}
    // the rating kind of this track
    @objc optional var releaseDate: Date {get}
    // the release date of this track
    @objc optional var sampleRate: Int {get}
    // the sample rate of the track (in Hz)
    @objc optional var seasonNumber: Int {get set}
    // the season number of the track
    @objc optional var shufflable: Bool {get set}
    // is this track included when shuffling?
    @objc optional var skippedCount: Int {get set}
    // number of times this track has been skipped
    @objc optional var skippedDate: Date {get set}
    // the date and time this track was last skipped
    @objc optional var show: String? {get set}
    // the show name of the track
    @objc optional var sortAlbum: String? {get set}
    // override string to use for the track when sorting by album
    @objc optional var sortArtist: String? {get set}
    // override string to use for the track when sorting by artist
    @objc optional var sortAlbumArtist: String? {get set}
    // override string to use for the track when sorting by album artist
    @objc optional var sortName: String? {get set}
    // override string to use for the track when sorting by name
    @objc optional var sortComposer: String? {get set}
    // override string to use for the track when sorting by composer
    @objc optional var sortShow: String? {get set}
    // override string to use for the track when sorting by show name
    @objc optional var size: CLong {get}
    // the size of the track (in bytes)
    @objc optional var start: Double {get set}
    // the start time of the track in seconds
    @objc optional var time: String? {get}
    // the length of the track in MM:SS format
    @objc optional var trackCount: Int {get set}
    // the total number of tracks on the source album
    @objc optional var trackNumber: Int {get set}
    // the index of the track on the source album
    @objc optional var unplayed: Bool {get set}
    // is this track unplayed?
    @objc optional var volumeAdjustment: Int {get set}
    // relative volume adjustment of the track (-100% to 100%)
    @objc optional var work: String? {get set}
    // the work name of the track
    @objc optional var year: Int {get set}
    // the year the track was recorded/released
}
extension SBObject: SBMusicTrack{}


// a track on an audio CD
@objc protocol MusicAudioCDTrack: SBMusicTrack {
    @objc optional var location: URL? {get}
    // the location of the file represented by this track
}
extension SBObject: MusicAudioCDTrack{}


// a track representing an audio file (MP3, AIFF, etc.)
@objc protocol MusicFileTrack: SBMusicTrack {
    @objc optional var location: URL? {get set}
    // the location of the file represented by this track
    @objc optional func refresh()
    // update file track information from the current information in the track’s file
}
extension SBObject: MusicFileTrack{}


// a track residing in a shared library
@objc protocol MusicSharedTrack: SBMusicTrack {
}
extension SBObject: MusicSharedTrack{}


// a track representing a network stream
@objc protocol MusicURLTrack: SBMusicTrack {
    @objc optional var address: String? {get set}
    // the URL for this track
}
extension SBObject: MusicURLTrack{}


// custom playlists created by the user
@objc protocol MusicUserPlaylist: MusicPlaylist {
    @objc optional func fileTracks() -> [MusicFileTrack]
    @objc optional func URLTracks() -> [MusicURLTrack]
    @objc optional func sharedTracks() -> [MusicSharedTrack]
    @objc optional var shared: Bool {get set}
    // is this playlist shared?
    @objc optional var smart: Bool {get}
    // is this a Smart Playlist?
    @objc optional var genius: Bool {get}
    // is this a Genius Playlist?
}
extension SBObject: MusicUserPlaylist{}


// a folder that contains other playlists
@objc protocol MusicFolderPlaylist: MusicUserPlaylist {
}
extension SBObject: MusicFolderPlaylist{}


// a visual plug-in
@objc protocol MusicVisual: MusicItem {
}
extension SBObject: MusicVisual{}


// any window
@objc protocol MusicWindow: MusicItem {
    @objc optional var bounds: NSRect {get set}
    // the boundary rectangle for the window
    @objc optional var closeable: Bool {get}
    // does the window have a close button?
    @objc optional var collapseable: Bool {get}
    // does the window have a collapse button?
    @objc optional var collapsed: Bool {get set}
    // is the window collapsed?
    @objc optional var fullScreen: Bool {get set}
    // is the window full screen?
    @objc optional var position: NSPoint {get set}
    // the upper left position of the window
    @objc optional var resizable: Bool {get}
    // is the window resizable?
    @objc optional var visible: Bool {get set}
    // is the window visible?
    @objc optional var zoomable: Bool {get}
    // is the window zoomable?
    @objc optional var zoomed: Bool {get set}
    // is the window zoomed?
}
extension SBObject: MusicWindow{}


// the main iTunes window
@objc protocol MusicBrowserWindow: MusicWindow {
    @objc optional var selection: SBObject {get}
    // the selected songs
    @objc optional var view: MusicPlaylist {get set}
    // the playlist currently displayed in the window
}
extension SBObject: MusicBrowserWindow{}


// the iTunes equalizer window
@objc protocol MusicEQWindow: MusicWindow {
}
extension SBObject: MusicEQWindow{}


// the miniplayer window
@objc protocol MusicMiniplayerWindow: MusicWindow {
}
extension SBObject: MusicMiniplayerWindow{}


// a sub-window showing a single playlist
@objc protocol MusicPlaylistWindow: MusicWindow {
    @objc optional var selection: SBObject {get}
    // the selected songs
    @objc optional var view: MusicPlaylist {get}
    // the playlist displayed in the window
}
extension SBObject: MusicPlaylistWindow{}


// the video window
@objc protocol MusicVideoWindow: MusicWindow {
}
extension SBObject: MusicVideoWindow{}

#endif

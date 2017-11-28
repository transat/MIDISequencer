//
//  MIDISequencer.swift
//  MIDISequencer
//
//  Created by Cem Olcay on 12/09/2017.
//
//

import Foundation
import AudioKit
import MusicTheorySwift

/// Sequencer with multiple tracks and multiple channels to broadcast MIDI sequences other apps.
public class MIDISequencer: AKMIDIListener {
  /// Name of the sequencer.
  public private(set) var name: String
  /// Sequencer that sequences the `MIDISequencerStep`s in each `MIDISequencerTrack`.
  public private(set) var sequencer: AKSequencer?
  /// Global MIDI referance object.
  public let midi = AKMIDI()
  /// All tracks in sequencer.
  public var tracks = [MIDISequencerTrack]()
  /// Tempo (BPM) and time signature value of sequencer.
  public var tempo = Tempo() { didSet{ sequencer?.setTempo(tempo.bpm) }}

  public var isPlaying: Bool {
    return sequencer?.isPlaying ?? false
  }

  // MARK: Init

  /// Initilizes the sequencer with its name.
  ///
  /// - Parameter name: Name of sequencer that seen by other apps.
  public init(name: String) {
    self.name = name
    midi.createVirtualInputPort(name: "\(name) In")
    midi.createVirtualOutputPort(name: "\(name) Out")
    midi.addListener(self)
  }

  deinit {
    midi.destroyVirtualPorts()
    stop()
  }

  /// Creates an `AKSequencer` from `tracks`
  private func setupSequencer() {
    sequencer = AKSequencer()
    
    for (index, track) in tracks.enumerated() {
      guard let newTrack = sequencer?.newTrack(track.name) else { continue }
      newTrack.setMIDIOutput(midi.virtualInput)

        for step in track.steps {
          let velocity = MIDIVelocity(step.velocity.velocity)
          let position = AKDuration(beats: step.position)
          let duration = AKDuration(beats: step.duration)

          for note in step.notes {
            let noteNumber = MIDINoteNumber(note.midiNote)

            newTrack.add(
              noteNumber: noteNumber,
              velocity: velocity,
              position: position,
              duration: duration,
              channel: MIDIChannel(index))
        }
      }
    }

    sequencer?.setTempo(tempo.bpm)
    sequencer?.enableLooping(AKDuration(beats: tracks.map({ $0.duration }).sorted().last ?? 0))
  }

  // MARK: Sequencing

  /// Plays the sequence from begining if any MIDI Output including virtual one setted up.
  public func play() {
    setupSequencer()
    sequencer?.play()
  }

  /// Setups sequencer on background thread and starts playing it.
  ///
  /// - Parameter completion: Fires when setup complete.
  public func playAsync(completion: (() -> Void)? = nil) {
    DispatchQueue.global(qos: .background).async {
      self.setupSequencer()
      DispatchQueue.main.async {
        self.sequencer?.play()
        completion?()
      }
    }
  }

  /// Stops playing the sequence.
  public func stop() {
    sequencer?.stop()
    sequencer = nil
  }

  // MARK: Track Management

  /// Adds a track to optional index.
  ///
  /// - Parameters:
  ///   - track: Adding track.
  ///   - index: Optional index of adding track. Appends end of array if not defined. Defaults nil.
  public func add(track: MIDISequencerTrack, at index: Int? = nil) {
    let trackIndex = index ?? tracks.count
    if tracks.count < 16, trackIndex > 0, trackIndex < 16 {
      tracks.insert(track, at: trackIndex)
    }
  }

  /// Removes a track.
  ///
  /// - Parameter track: Track going to be removed.
  /// - Returns: Returns result of removing operation in discardableResult form.
  @discardableResult public func remove(track: MIDISequencerTrack) -> Bool {
    guard let index = tracks.index(of: track) else { return false }
    tracks.remove(at: index)
    return true
  }

  /// Sets mute state of track to true.
  ///
  /// - Parameter on: Set mute or not.
  /// - Parameter track: Track going to be mute.
  /// - Returns: If track is not this sequenecer's, return false, else return true.
  @discardableResult public func mute(on: Bool, track: MIDISequencerTrack) -> Bool {
    guard let index = tracks.index(of: track) else { return false }
    tracks[index].isMute = on
    return true
  }

  /// Sets solo state of track to true.
  ///
  /// - Parameter on: Set solo or not.
  /// - Parameter track: Track going to be enable soloing.
  /// - Returns: If track is not this sequenecer's, return false, else return true.
  @discardableResult public func solo(on: Bool, track: MIDISequencerTrack) -> Bool {
    guard let index = tracks.index(of: track) else { return false }
    tracks[index].isSolo = on
    return true
  }

  // MARK: AKMIDIListener

  public func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
    guard sequencer?.isPlaying == true, tracks.indices.contains(Int(channel)) else {
      midi.sendNoteOffMessage(noteNumber: noteNumber, velocity: velocity)
      return
    }

    let track = tracks[Int(channel)]
    for trackChannel in track.midiChannels {
      midi.sendNoteOnMessage(
        noteNumber: noteNumber,
        velocity: track.isMute ? 0 : velocity,
        channel: MIDIChannel(trackChannel))
    }
  }

  public func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
    guard sequencer?.isPlaying == true,
      tracks.indices.contains(Int(channel))
      else { return }

    let track = tracks[Int(channel)]
    for trackChannel in track.midiChannels {
      midi.sendNoteOffMessage(
        noteNumber: noteNumber,
        velocity: velocity,
        channel: MIDIChannel(trackChannel))
    }
  }
}

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
public class MIDISequencer {
  /// Name of the sequencer.
  public private(set) var midiOutputName: String
  /// MIDI callback instrument that sends MIDI events to other apps.
  private var midiCallbackInstrument: MIDISequencerCallbackInstrument
  /// Global MIDI referance object.
  private let midi = AKMIDI()
  /// Sequencer that sequences the `MIDISequencerStep`s in each `MIDISequencerTrack`.
  public private(set) var sequencer: AKSequencer?

  /// All tracks in sequencer.
  public var tracks = [MIDISequencerTrack]()
  /// Tempo (BPM) and time signature value of sequencer.
  public var tempo = Tempo(timeSignature: TimeSignature(beats: 4, noteValue: .quarter), bpm: 120) { didSet{ sequencer?.setTempo(tempo.bpm) }}

  /// Initilizes the sequencer with its name.
  ///
  /// - Parameter midiOutputName: Name of sequencer that seen by other apps.
  public init(midiOutputName: String) {
    self.midiOutputName = midiOutputName
    midiCallbackInstrument = MIDISequencerCallbackInstrument(midi: midi)
    midi.createVirtualOutputPort(name: midiOutputName)
  }

  deinit {
    stop()
  }

  /// Creates an `AKSequencer` from `tracks`
  private func setupSequencer() {
    sequencer = AKSequencer()

    for track in tracks {
      guard let newTrack = sequencer?.newTrack(track.name) else { continue }
      newTrack.setMIDIOutput(midiCallbackInstrument.midiIn)
      for (index, step) in track.steps.enumerated() {
        if step.isMuted { continue }
        for note in step.notes {
          newTrack.add(
            noteNumber: MIDINoteNumber(note.midiNote),
            velocity: MIDIVelocity(step.velocity.velocity),
            position: AKDuration(beats: Double(index)),
            duration: AKDuration(seconds: tempo.duration(of: step.noteValue)),
            channel: MIDIChannel(track.midiChannel))
        }
      }
    }

    sequencer?.setTempo(tempo.bpm)
    sequencer?.enableLooping(AKDuration(beats: Double(tracks.map({ $0.steps.count }).sorted().first ?? 0)))
  }

  /// Plays the sequence from begining.
  public func play() {
    setupSequencer()
    sequencer?.play()
  }

  /// Setups sequencer on background thread and starts playing it.
  ///
  /// - Parameter completion: Fires when setup complete. Useful to dismiss any loading state.
  public func playAsync(completion: (() -> Void)? = nil) {
    DispatchQueue.main.async {
      self.play()
      completion?()
    }
  }

  /// Stops playing the sequence.
  public func stop() {
    sequencer?.stop()
    sequencer = nil
  }
}

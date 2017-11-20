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
  /// Sequencer that sequences the `MIDISequencerStep`s in each `MIDISequencerTrack`.
  public private(set) var sequencer: AKSequencer?
  /// Global MIDI referance object.
  public let midi = AKMIDI()
  /// MIDI callback instrument that sends MIDI events to other apps.
  public private(set) var midiCallbackInstrument: MIDISequencerCallbackInstrument

  /// All tracks in sequencer.
  public var tracks = [MIDISequencerTrack]()
  /// Tempo (BPM) and time signature value of sequencer.
  public var tempo = Tempo() { didSet{ sequencer?.setTempo(tempo.bpm) }}

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

        for step in track.steps {
          for note in step.notes {
            for channel in track.midiChannels {
            newTrack.add(
              noteNumber: MIDINoteNumber(note.midiNote),
              velocity: MIDIVelocity(step.velocity.velocity),
              position: AKDuration(beats: step.position),
              duration: AKDuration(beats: step.duration),
              channel: MIDIChannel(channel))
          }
        }
      }
    }
    
    sequencer?.setTempo(tempo.bpm)
    sequencer?.enableLooping(AKDuration(beats: tracks.map({ $0.duration }).sorted().last ?? 0))
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
}

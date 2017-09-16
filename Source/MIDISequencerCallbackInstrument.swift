//
//  MIDISequencerCallbackInstrument.swift
//  MIDISequencer
//
//  Created by Cem Olcay on 12/09/2017.
//
//

import Foundation
import AudioKit

/// MIDI callback instrument that sends MIDI events in `AKSequencer` to other apps.
public class MIDISequencerCallbackInstrument: AKCallbackInstrument {
  /// Global MIDI referance to broadcast MIDI callbacks from `MIDISequencer` to other apps.
  public var midi: AKMIDI

  /// Initilizes the instrument with global MIDI referance.
  ///
  /// - Parameter midi: MIDI reference in `MIDISequnecer`.
  public init(midi: AKMIDI) {
    self.midi = midi
    super.init(callback: nil)
  }

  public override func start(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
    midi.sendNoteOnMessage(noteNumber: noteNumber, velocity: velocity, channel: channel)
  }

  public override func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel) {
    midi.sendNoteOffMessage(noteNumber: noteNumber, velocity: 0, channel: channel)
  }
}

//
//  MIDISequencerStep.swift
//  MIDISequencer
//
//  Created by Cem Olcay on 12/09/2017.
//
//

import Foundation
import AudioKit
import MusicTheorySwift

/// Velocity of notes in a step.
public enum MIDISequencerStepVelocity {
  /// Static velocity that not changed.
  case standard(Int)
  /// Random velocity between min and max values that changed in every loop.
  case random(min: Int, max: Int)

  /// Returns the velocity value.
  public var velocity: Int {
    switch self {
    case .standard(let velocity):
      return velocity
    case .random(let min, let max):
      return Int(arc4random_uniform(UInt32(max - min))) + min
    }
  }
}

/// A step in a `MIDISequencerTrack` of `MIDISequencer`.
public struct MIDISequencerStep {
  /// Notes in step.
  public var notes: [Note]
  /// Note value of each notes in step.
  public var noteValue: NoteValue
  /// Velocity if each notes in step.
  public var velocity: MIDISequencerStepVelocity
  /// Use that proprety to mute/unmute step.
  public var isMuted = false
  /// Informs that if step is empty or not.
  public var isEmpty: Bool {
    return notes.isEmpty
  }

  /// Creates muted, empty step.
  public init() {
    self.init(notes: [], noteValue: NoteValue(type: .quarter), velocity: .standard(0))
    isMuted = true
  }

  /// Initilizes the step with multiple notes.
  ///
  /// - Parameters:
  ///   - notes: Notes in step.
  ///   - noteValue: Note value of each note in step.
  ///   - velocity: Velocity of each note in step.
  public init(notes: [Note], noteValue: NoteValue, velocity: MIDISequencerStepVelocity) {
    self.notes = notes
    self.noteValue = noteValue
    self.velocity = velocity
  }

  /// Initilizes the step with single note.
  ///
  /// - Parameters:
  ///   - note: Note in step.
  ///   - noteValue: Note value of note in step.
  ///   - velocity: Velocity of note in step.
  public init(note: Note, noteValue: NoteValue, velocity: MIDISequencerStepVelocity) {
    self.init(notes: [note], noteValue: noteValue, velocity: velocity)
  }

  /// Initilizes the step with a chord in desired octave.
  ///
  /// - Parameters:
  ///   - chord: Desierd chord in step.
  ///   - octave: Octave of chord in step.
  ///   - noteValue: Note value of chord in step.
  ///   - velocity: Velocity of chord in step.
  public init(chord: Chord, octave: Int, noteValue: NoteValue, velocity: MIDISequencerStepVelocity) {
    self.init(notes: chord.notes(octave: octave), noteValue: noteValue, velocity: velocity)
  }
}

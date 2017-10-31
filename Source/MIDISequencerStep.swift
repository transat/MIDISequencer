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
public enum MIDISequencerStepVelocity: Codable {
  /// Static velocity that not changed.
  case standard(Int)
  /// Maximum velociy which is 127.
  case max
  /// Zero velocity.
  case muted
  /// Random velocity between min and max values that changed in every loop.
  case random(min: Int, max: Int)

  /// Initilize velocity. No random type possible.
  ///
  /// - Parameter velocity: Velocity value.
  public init(velocity: Int) {
    if velocity == 0 {
      self = .muted
    } else if velocity == 127 {
      self = .max
    } else {
      self = .standard(velocity)
    }
  }

  /// Returns the velocity value.
  public var velocity: Int {
    switch self {
    case .standard(let velocity):
      return velocity
    case .max:
      return 127
    case .muted:
      return 0
    case .random(let min, let max):
      return Int(arc4random_uniform(UInt32(max - min))) + min
    }
  }

  // MARK: Codable

  /// Keys that conforms CodingKeys protocol to map properties.
  private enum CodingKeys: String, CodingKey {
    /// Velocity value of `MIDISequencerStepVelocity`.
    case velocity
  }

  /// Decodes struct with a decoder.
  ///
  /// - Parameter decoder: Decodes encoded struct.
  /// - Throws: Tries to initlize struct with a decoder.
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let velocity = try values.decode(Int.self, forKey: .velocity)
    self = MIDISequencerStepVelocity(velocity: velocity)
  }

  /// Encodes struct with an ecoder.
  ///
  /// - Parameter encoder: Encodes struct.
  /// - Throws: Tries to encode struct.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(velocity, forKey: .velocity)
  }
}

/// A step in a `MIDISequencerTrack` of `MIDISequencer`.
public struct MIDISequencerStep: Codable {
  /// Notes in step.
  public var notes: [Note]
  /// Position in track, in form of beats.
  public var position: Double
  /// Duration of step, in form of beats.
  public var duration: Double
  /// Velocity if each notes in step.
  public var velocity: MIDISequencerStepVelocity

  /// Initilizes the step with multiple notes.
  ///
  /// - Parameters:
  ///   - notes: Notes in step.
  ///   - position: Position in track, in form of beats.
  ///   - duration: Duration of step, in form of beats.
  ///   - velocity: Velocity of each note in step.
  public init(notes: [Note], position: Double, duration: Double, velocity: MIDISequencerStepVelocity) {
    self.notes = notes
    self.position = position
    self.duration = duration
    self.velocity = velocity
  }

  /// Initilizes the step with single note.
  ///
  /// - Parameters:
  ///   - note: Note in step.
  ///   - position: Position in track, in form of beats.
  ///   - duration: Duration of step, in form of beats.
  ///   - velocity: Velocity of note in step.
  public init(note: Note, position: Double, duration: Double, velocity: MIDISequencerStepVelocity) {
    self.init(notes: [note], position: position, duration: duration, velocity: velocity)
  }

  /// Initilizes the step with a chord in desired octave.
  ///
  /// - Parameters:
  ///   - chord: Desierd chord in step.
  ///   - octave: Octave of chord in step.
  ///   - position: Position in track, in form of beats.
  ///   - duration: Duration of step, in form of beats.
  ///   - velocity: Velocity of chord in step.
  public init(chord: Chord, octave: Int, position: Double, duration: Double, velocity: MIDISequencerStepVelocity) {
    self.init(notes: chord.notes(octave: octave), position: position, duration: duration, velocity: velocity)
  }

  /// Creates an empty, muted step.
  ///
  /// - Parameters:
  ///   - position: Position in track, in form of beats.
  ///   - duration: Duration of step, in form of beats.
  public init(position: Double, duration: Double) {
    self.init(notes: [], position: position, duration: duration, velocity: .muted)
  }
}

//
//  MIDISequencerArpeggiator.swift
//  MIDISequencer
//
//  Created by Cem Olcay on 16/09/2017.
//
//

import Foundation
import AudioKit
import MusicTheorySwift

/// `MIDISequencerArpeggiator`'s arpeggio style.
public enum MIDISequencerArpeggio {
  /// Arpeggiates notes from start to end.
  case up
  /// Arpeggiates notes from end to start.
  case down
  /// Arpeggiates note from start to end and arpeggiates again from end to start.
  case updown
  /// Arpeggiates notes in random order.
  case random
}

/// Arpeggiator with arpeggio style and notes that will be arpeggiated.
public struct MIDISequencerArpeggiator {
  /// Notes will be arpeggiated.
  public var notes: [NoteType]
  /// Arpeggio style.
  public var arpeggio: MIDISequencerArpeggio
  /// Octave range of arpeggiator.
  public var octaves: [Int]

  /// Initilizes arpeggiator with notes, arpeggio style and octave range.
  ///
  /// - Parameters:
  ///   - note: Notes will be arpeggiated.
  ///   - arpeggio: Arpeggio style.
  ///   - octaves: Octave range of notes.
  public init(note: NoteType, arpeggio: MIDISequencerArpeggio, octaves: [Int]) {
    self.notes = [note]
    self.arpeggio = arpeggio
    self.octaves = octaves
  }

  /// Initilizes arpeggiator with notes in scale with their octave range and arpeggio style.
  ///
  /// - Parameters:
  ///   - scale: Notes in scale will be arpeggiated.
  ///   - arpeggio: Arpeggio style.
  ///   - octaves: Octave range of notes.
  public init(scale: Scale, arpeggio: MIDISequencerArpeggio, octaves: [Int]) {
    self.notes = scale.noteTypes
    self.arpeggio = arpeggio
    self.octaves = octaves
  }

  /// Initilizes arpeggiator with notes in chord with their octave range and arpeggio style.
  ///
  /// - Parameters:
  ///   - chord: Notes in chord will be arpeggiated.
  ///   - arpeggio: Arpeggio style.
  ///   - octaves: Octave range of notes.
  public init(chord: Chord, arpeggio: MIDISequencerArpeggio, octaves: [Int]) {
    self.notes = chord.noteTypes
    self.arpeggio = arpeggio
    self.octaves = octaves
  }

  /// Generates `MIDISequencerStep`s from notes in arpeggio style order with note values and velocities.
  ///
  /// - Parameters:
  ///   - noteValue: Values of each note in arpeggiator.
  ///   - velocity: Velocities of each note in arpeggiator.
  /// - Returns: `MIDISequencerStep`s from arpeggiator.
  public func steps(noteValue: NoteValue, velocity: MIDISequencerStepVelocity) -> [MIDISequencerStep] {
    var stepNotes = [MIDISequencerStep]()
    for octave in octaves {
      for type in notes {
        stepNotes.append(MIDISequencerStep(
          note: Note(type: type, octave: octave),
          noteValue: noteValue,
          velocity: velocity))
      }
    }

    switch arpeggio {
    case .up:
      return stepNotes
    case .down:
      return stepNotes.reversed()
    case .updown:
      return stepNotes + stepNotes.reversed()
    case .random:
      if stepNotes.count < 2 { return stepNotes }

      for i in stepNotes.startIndex ..< stepNotes.endIndex - 1 {
        let j = Int(arc4random_uniform(UInt32(stepNotes.endIndex - i))) + i
        if i != j {
          swap(&stepNotes[i], &stepNotes[j])
        }
      }

      return stepNotes
    }
  }
}

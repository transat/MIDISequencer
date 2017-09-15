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

public enum MIDISequencerArpeggio {
  case up
  case down
  case updown
  case random
}

public struct MIDISequencerArpeggiator {
  public var notes: [NoteType]
  public var arpeggio: MIDISequencerArpeggio
  public var octaves: [Int]

  public init(note: NoteType, arpeggio: MIDISequencerArpeggio, octaves: [Int]) {
    self.notes = [note]
    self.arpeggio = arpeggio
    self.octaves = octaves
  }

  public init(scale: Scale, arpeggio: MIDISequencerArpeggio, octaves: [Int]) {
    self.notes = scale.noteTypes
    self.arpeggio = arpeggio
    self.octaves = octaves
  }

  public init(chord: Chord, arpeggio: MIDISequencerArpeggio, octaves: [Int]) {
    self.notes = chord.noteTypes
    self.arpeggio = arpeggio
    self.octaves = octaves
  }

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

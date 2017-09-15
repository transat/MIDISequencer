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

private extension Collection where Indices.Iterator.Element == Index {
  subscript (safe index: Index) -> Generator.Element? {
    return indices.contains(index) ? self[index] : nil
  }
}

public enum MIDISequencerStepNoteVelocity {
  case standard(Int)
  case random(min: Int, max: Int)

  public var velocity: Int {
    switch self {
    case .standard(let velocity):
      return velocity
    case .random(let min, let max):
      return Int(arc4random_uniform(UInt32(max - min))) + min
    }
  }
}

public struct MIDISequencerStepNote {
  public var note: Note
  public var noteValue: NoteValue
  public var velocity: MIDISequencerStepNoteVelocity

  public init(note: Note, noteValue: NoteValue, velocity: MIDISequencerStepNoteVelocity) {
    self.note = note
    self.noteValue = noteValue
    self.velocity = velocity
  }
}

public indirect enum MIDISequencerStep {
  case empty
  case muted(step: MIDISequencerStep)
  case step(notes: [MIDISequencerStepNote])
  case continues(parent: MIDISequencerStep)
}

public class MIDISequencerTrack {
  public var name: String
  public var midiChannel: Int
  public var steps: [MIDISequencerStep]

  public init(name: String, midiChannel: Int = 0, steps: [MIDISequencerStep] = []) {
    self.name = name
    self.midiChannel = midiChannel
    self.steps = steps
  }

  public func addNext(step: MIDISequencerStep) {
    add(step: step, at: steps.count)
  }

  public func add(step: MIDISequencerStep, at index: Int) {
    steps.insert(step, at: index)
  }

  public func add(steps: [MIDISequencerStep], at index: Int = 0) {
    self.steps.insert(contentsOf: steps, at: index)
  }

  public func remove(at index: Int) {
    steps.remove(at: index)
  }

  public func clear() {
    steps = []
  }
}

private class MIDISequencerCallbackInstrument: AKCallbackInstrument {
  var midi: AKMIDI

  init(midi: AKMIDI) {
    self.midi = midi
    super.init(callback: nil)
  }

  override func start(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
    midi.sendNoteOnMessage(noteNumber: noteNumber, velocity: velocity, channel: channel)
    print("note on \(noteNumber)")
  }

  override func stop(noteNumber: MIDINoteNumber, channel: MIDIChannel) {
    midi.sendNoteOffMessage(noteNumber: noteNumber, velocity: 0, channel: channel)
    print("note off \(noteNumber)")
  }
}

public class MIDISequencer {
  public private(set) var midiOutputName: String
  private var midiCallbackInstrument: MIDISequencerCallbackInstrument
  private let midi = AKMIDI()
  private var sequencer: AKSequencer?

  public var tracks = [MIDISequencerTrack]() { didSet{ setupSequencer() }}
  public var tempo = Tempo(timeSignature: TimeSignature(beats: 4, noteValue: .quarter), bpm: 120) { didSet{ sequencer?.setTempo(tempo.bpm) }}

  /// Current step on sequencer
  private var currentStep = 0
  /// Calculated before playing by the track that has maximum amount of steps.
  private var stepCount = 0

  public init(midiOutputName: String) {
    self.midiOutputName = midiOutputName
    midiCallbackInstrument = MIDISequencerCallbackInstrument(midi: midi)
    midi.createVirtualOutputPort(name: midiOutputName)
  }

  private func setupSequencer() {
    sequencer = AKSequencer()
    currentStep = 0
    stepCount = tracks.map({ $0.steps.count }).sorted().first ?? 0

    for track in tracks {
      guard let newTrack = sequencer?.newTrack(track.name) else { continue }
      newTrack.setMIDIOutput(midiCallbackInstrument.midiIn)
      for (index, step) in track.steps.enumerated() {
        switch step {
        case .step(let notes):
          for note in notes {
            newTrack.add(
              noteNumber: MIDINoteNumber(note.note.midiNote),
              velocity: MIDIVelocity(note.velocity.velocity),
              position: AKDuration(beats: Double(index)),
              duration: AKDuration(seconds: tempo.duration(of: note.noteValue)),
              channel: MIDIChannel(track.midiChannel))
          }
        default:
          continue
        }
      }
    }

    sequencer?.setTempo(tempo.bpm)
    sequencer?.enableLooping(AKDuration(beats: Double(stepCount)))
  }

  public func play() {
    setupSequencer()
    sequencer?.play()
  }

  public func stop() {
    sequencer?.stop()
    sequencer = nil
  }
}

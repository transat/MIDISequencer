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

public class MIDISequencer {
  public private(set) var midiOutputName: String
  private var midiCallbackInstrument: AKCallbackInstrument
  private let midi = AKMIDI()
  private let sequencer = AKSequencer()

  public var tracks = [MIDISequencerTrack]() { didSet{ setupSequencer() }}
  public var tempo = Tempo(timeSignature: TimeSignature(beats: 4, noteValue: .quarter), bpm: 120) { didSet{ sequencer.setTempo(tempo.bpm) }}

  /// Current step on sequencer
  private var currentStep = 0
  /// Calculated before playing by the track that has maximum amount of steps.
  private var stepCount = 0

  public init(midiOutputName: String) {
    self.midiOutputName = midiOutputName
    self.midiCallbackInstrument = AKCallbackInstrument(callback: nil)
    self.midiCallbackInstrument.callback = midiCallback
    midi.createVirtualOutputPort(name: midiOutputName)
    setupSequencer()
  }

  private func setupSequencer() {
    sequencer.stop()
    sequencer.preroll()
    currentStep = 0
    stepCount = tracks.map({ $0.steps.count }).sorted().first ?? 0

    guard let track = sequencer.newTrack() else { return }
    track.add(
      noteNumber: 0,
      velocity: 10,
      position: AKDuration(beats: 0),
      duration: AKDuration(seconds: tempo.duration(of: NoteValue(type: tempo.timeSignature.noteValue))))

    sequencer.setGlobalMIDIOutput(midiCallbackInstrument.midiIn)
    sequencer.setTempo(tempo.bpm)
    sequencer.setLoopInfo(AKDuration(beats: 1), numberOfLoops: 0)
    sequencer.tracks = [track]
  }

  private func midiCallback(status: AKMIDIStatus, noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {

    print("\(Date()) \(status) \(currentStep)")

    switch status {
    case .noteOn:
      for track in tracks {
        guard let step = track.steps[safe: currentStep] else { break }
        switch step {
        case .step(let notes):
          for note in notes {
            midi.sendNoteOnMessage(
              noteNumber: MIDINoteNumber(note.note.midiNote),
              velocity: MIDIVelocity(note.velocity.velocity),
              channel: MIDIChannel(track.midiChannel))
          }
        default:
          break
        }

        currentStep += 1
        if currentStep >= stepCount {
          currentStep = 0
        }
      }
    case .noteOff:
      for track in tracks {
        guard let step: MIDISequencerStep = currentStep == 0 ? track.steps[safe: stepCount-1] : track.steps[safe: currentStep-1] else { return }
        switch step {
        case .step(let notes):
          for note in notes {
            midi.sendNoteOffMessage(
              noteNumber: MIDINoteNumber(note.note.midiNote),
              velocity: 0,
              channel: MIDIChannel(track.midiChannel))
          }
        default:
          break
        }
      }
    default:
      break
    }
  }

  public func play() {
    setupSequencer()
    sequencer.play()
  }

  public func stop() {
    sequencer.stop()
  }
}

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
  /// Returns optional value from index to bypass "index out of range" error.
  subscript (safe index: Index) -> Generator.Element? {
    return indices.contains(index) ? self[index] : nil
  }
}

/// Velocity of notes in a step.
public enum MIDISequencerStepNoteVelocity {
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
  public var velocity: MIDISequencerStepNoteVelocity
  /// Use that proprety to mute/unmute step.
  public var isMuted = false

  /// Creates muted, empty step
  public init() {
    notes = []
    noteValue = NoteValue(type: .quarter)
    velocity = .standard(0)
    isMuted = true
  }

  /// Initilizes the step with multiple notes.
  ///
  /// - Parameters:
  ///   - notes: Notes in step.
  ///   - noteValue: Note value of each note in step.
  ///   - velocity: Velocity of each note in step.
  public init(notes: [Note], noteValue: NoteValue, velocity: MIDISequencerStepNoteVelocity) {
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
  public init(note: Note, noteValue: NoteValue, velocity: MIDISequencerStepNoteVelocity) {
    self.init(notes: [note], noteValue: noteValue, velocity: velocity)
  }

  /// Initilizes the step with a chord in desired octave.
  ///
  /// - Parameters:
  ///   - chord: Desierd chord in step.
  ///   - octave: Octave of chord in step.
  ///   - noteValue: Note value of chord in step.
  ///   - velocity: Velocity of chord in step.
  public init(chord: Chord, octave: Int, noteValue: NoteValue, velocity: MIDISequencerStepNoteVelocity) {
    self.init(notes: chord.notes(octave: octave), noteValue: noteValue, velocity: velocity)
  }
}

/// A track that has `MIDISequencerStep`s in `MIDISequencer`.
public class MIDISequencerTrack {
  /// Name of track.
  public var name: String
  /// MIDI Channel of track to send notes to.
  public var midiChannel: Int
  /// Steps in track.
  public var steps: [MIDISequencerStep]

  /// Initilizes the track with name and optional channel and steps properties. You can always change its steps and channel after created it.
  ///
  /// - Parameters:
  ///   - name: Name of track.
  ///   - midiChannel: Channel of track to send notes to. Defaults 0.
  ///   - steps: Steps in track. Defaults empty.
  public init(name: String, midiChannel: Int = 0, steps: [MIDISequencerStep] = []) {
    self.name = name
    self.midiChannel = midiChannel
    self.steps = steps
  }

  /// Adds step at the end of sequence.
  ///
  /// - Parameter step: Step to add to end of sequence.
  public func addNext(step: MIDISequencerStep) {
    add(step: step, at: steps.count)
  }

  /// Adds a step to sequence at index.
  ///
  /// - Parameters:
  ///   - step: Step to add to sequence.
  ///   - index: Index of step to add.
  public func add(step: MIDISequencerStep, at index: Int) {
    steps.insert(step, at: index)
  }

  /// Adds multiple steps to sequence at index.
  ///
  /// - Parameters:
  ///   - steps: Steps to add to sequence.
  ///   - index: Inserting index to sequence. Defaults 0.
  public func add(steps: [MIDISequencerStep], at index: Int = 0) {
    self.steps.insert(contentsOf: steps, at: index)
  }

  /// Removes a step at index.
  ///
  /// - Parameter index: Index of step to remove.
  public func remove(at index: Int) {
    steps.remove(at: index)
  }

  /// Remove all steps.
  public func clear() {
    steps = []
  }
}

/// MIDI callback instrument that sends MIDI events in `AKSequencer` to other apps.
private class MIDISequencerCallbackInstrument: AKCallbackInstrument {
  /// Global MIDI referance to broadcast MIDI callbacks from `MIDISequencer` to other apps.
  var midi: AKMIDI

  /// Initilizes the instrument with global MIDI referance.
  ///
  /// - Parameter midi: MIDI reference in `MIDISequnecer`.
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

/// Sequencer with multiple tracks and multiple channels to broadcast MIDI sequences other apps.
public class MIDISequencer {
  /// Name of the sequencer.
  public private(set) var midiOutputName: String
  /// MIDI callback instrument that sends MIDI events to other apps.
  private var midiCallbackInstrument: MIDISequencerCallbackInstrument
  /// Global MIDI referance object.
  private let midi = AKMIDI()
  /// Sequencer that sequences the `MIDISequencerStep`s in each `MIDISequencerTrack`.
  private var sequencer: AKSequencer?

  /// All tracks in sequencer.
  public var tracks = [MIDISequencerTrack]() { didSet{ setupSequencer() }}
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
    sequencer?.enableLooping(AKDuration(beats: sequencer!.length.beats + 1))
  }

  /// Plays the sequence from begining.
  public func play() {
    setupSequencer()
    sequencer?.play()
  }

  /// Stops playing the sequence.
  public func stop() {
    sequencer?.stop()
    sequencer = nil
  }
}

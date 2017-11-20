//
//  ViewController.swift
//  Example Mac
//
//  Created by Cem Olcay on 13/09/2017.
//
//

import Cocoa
import MIDISequencer
import MusicTheorySwift

class ViewController: NSViewController {
  @IBOutlet weak var toggleButton: NSButton?
  let sequencer = MIDISequencer(midiOutputName: "Baby Steps")

  var isPlaying = false {
    didSet {
      if isPlaying {
        toggleButton?.title = "Stop"
        sequencer.play()
      } else {
        toggleButton?.title = "Play"
        sequencer.stop()
      }
    }
  }

  @IBAction func buttonDidToggle(sender: NSButton) {
    isPlaying = !isPlaying
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    isPlaying = false
    sequencer.tempo = Tempo(
      timeSignature: TimeSignature(
        beats: 4,
        noteValue: .quarter),
      bpm: 80)

    let bassVolume = MIDISequencerStepVelocity.standard(100)
    let bass = MIDISequencerTrack(
      name: "Bass",
      midiChannels: [1],
      steps: [
        MIDISequencerStep(
          note: Note(type: .a, octave: 3), 
          position: 0.0,
          duration: 0.5,
          velocity: bassVolume),
        MIDISequencerStep(
          note: Note(type: .a, octave: 3),
          position: 0.5,
          duration: 0.5,
          velocity: bassVolume),
        MIDISequencerStep(
          note: Note(type: .d, octave: 3),
          position: 1.0,
          duration: 0.5,
          velocity: bassVolume),
        MIDISequencerStep(
          note: Note(type: .a, octave: 3),
          position: 1.5,
          duration: 0.5,
          velocity: bassVolume),
        MIDISequencerStep(
          note: Note(type: .e, octave: 3),
          position: 2.0,
          duration: 0.25,
          velocity: bassVolume),
        MIDISequencerStep(
          note: Note(type: .d, octave: 3),
          position: 2.25,
          duration: 0.25,
          velocity: bassVolume),
        MIDISequencerStep(
          note: Note(type: .a, octave: 3),
          position: 2.5,
          duration: 0.25,
          velocity: bassVolume),
        MIDISequencerStep(
          note: Note(type: .e, octave: 3),
          position: 2.75,
          duration: 0.25,
          velocity: bassVolume),
      ])

    let chordsVolume = MIDISequencerStepVelocity.standard(100)
    let chords = MIDISequencerTrack(
      name: "Chords",
      midiChannels: [2],
      steps: [
        MIDISequencerStep(
          chord: Chord(type: ChordType(third: .minor), key: .a),
          octave: 4,
          position: 0.0,
          duration: 0.5,
          velocity: chordsVolume),
        MIDISequencerStep(
          chord: Chord(type: ChordType(third: .minor), key: .a),
          octave: 4,
          position: 0.5,
          duration: 0.5,
          velocity: chordsVolume),
        MIDISequencerStep(
          chord: Chord(type: ChordType(third: .minor), key: .d),
          octave: 4,
          position: 1.0,
          duration: 0.5,
          velocity: chordsVolume),
        MIDISequencerStep(
          chord: Chord(type: ChordType(third: .minor), key: .a),
          octave: 4,
          position: 1.5,
          duration: 0.5,
          velocity: chordsVolume),
        MIDISequencerStep(
          chord: Chord(type: ChordType(third: .minor), key: .e),
          octave: 4,
          position: 2.0,
          duration: 0.25,
          velocity: chordsVolume),
        MIDISequencerStep(
          chord: Chord(type: ChordType(third: .minor), key: .d),
          octave: 4,
          position: 2.25,
          duration: 0.25,
          velocity: chordsVolume),
        MIDISequencerStep(
          chord: Chord(type: ChordType(third: .minor), key: .a),
          octave: 4,
          position: 2.5,
          duration: 0.25,
          velocity: chordsVolume),
        MIDISequencerStep(
          chord: Chord(type: ChordType(third: .minor), key: .e),
          octave: 4,
          position: 2.75,
          duration: 0.25,
          velocity: chordsVolume),
      ])

    let arpeggiator = MIDISequencerArpeggiator(
      scale: Scale(type: .blues, key: .a),
      arpeggio: .random,
      octaves: [4, 5])

    let melody = MIDISequencerTrack(
      name: "Melody",
      midiChannels: [3],
      steps: arpeggiator.steps(
        position: 0,
        duration: 0.25,
        velocity: .random(min: 80, max: 120)))

    sequencer.addTrack(track: bass)
    sequencer.addTrack(track: chords)
    sequencer.addTrack(track: melody)
  }
}

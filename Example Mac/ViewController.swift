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
    arpeggiatorExample()
  }

  func sequencerExample() {
    let track1 = MIDISequencerTrack(
      name: "Track 1",
      midiChannel: 1)

    track1.steps = [
      MIDISequencerStep(
        note: Note(type: .c, octave: 4),
        noteValue: NoteValue(type: .quarter),
        velocity: .standard(100)),
      MIDISequencerStep(
        note: Note(type: .d, octave: 4),
        noteValue: NoteValue(type: .quarter),
        velocity: .standard(100)),
      MIDISequencerStep(
        note: Note(type: .e, octave: 4),
        noteValue: NoteValue(type: .quarter),
        velocity: .standard(100)),
      MIDISequencerStep(
        note: Note(type: .f, octave: 4),
        noteValue: NoteValue(type: .quarter),
        velocity: .standard(100)),
    ]

    let track2 = MIDISequencerTrack(
      name: "Track 2",
      midiChannel: 2,
      steps: [
        MIDISequencerStep(
          chord: Chord(type: .maj, key: .c),
          octave: 4,
          noteValue: NoteValue(type: .quarter),
          velocity: .standard(60)),
        MIDISequencerStep(
          chord: Chord(type: .maj, key: .c),
          octave: 4,
          noteValue: NoteValue(type: .quarter),
          velocity: .standard(60)),
        MIDISequencerStep(
          chord: Chord(type: .min, key: .a),
          octave: 4,
          noteValue: NoteValue(type: .quarter),
          velocity: .standard(60)),
        MIDISequencerStep(
          chord: Chord(type: .min, key: .a),
          octave: 4,
          noteValue: NoteValue(type: .quarter),
          velocity: .standard(60)),
        ])

    sequencer.tracks.append(track1)
    sequencer.tracks.append(track2)
  }

  func arpeggiatorExample() {
    let arpeggiator = MIDISequencerArpeggiator(
      chord: Chord(type: .maj, key: .c),
      arpeggio: .random,
      octaves: [4, 5])

    let track = MIDISequencerTrack(
      name: "Arp Track",
      midiChannel: 1,
      steps: arpeggiator.steps(
        noteValue: NoteValue(type: .sixtenth),
        velocity: .standard(100)))

    sequencer.addTrack(track: track)
    sequencer.tempo = Tempo(timeSignature: TimeSignature(beats: 4, noteValue: .quarter), bpm: 120)
  }
}

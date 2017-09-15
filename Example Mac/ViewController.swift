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
  let sequencer = MIDISequencer(midiOutputName: "Baby Steps")
  @IBOutlet weak var toggleButton: NSButton?

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

    track1.steps[1].isMuted = true
    sequencer.tracks.append(track1)
    sequencer.tracks.append(track2)
  }
}

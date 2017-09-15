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

    let track = MIDISequencerTrack(
      name: "Track 1",
      steps: [

//        MIDISequencerStep(
//          chord: Chord(type: .maj, key: .c),
//          octave: 4,
//          noteValue: NoteValue(type: .whole),
//          velocity: .standard(100)),

//        MIDISequencerStep(
//          note: Note(type: .c, octave: 4),
//          noteValue: NoteValue(type: .quarter),
//          velocity: .standard(100)),

        MIDISequencerStep(
          notes: Chord(type: .maj, key: .c).notes(octave: 4) + [Note(type: .c, octave: 6)],
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
      ])

    sequencer.tracks.append(track)
  }
}

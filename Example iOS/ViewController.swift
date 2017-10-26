//
//  ViewController.swift
//  Example iOS
//
//  Created by Cem Olcay on 26.10.2017.
//

import UIKit
import MIDISequencer
import MusicTheorySwift

class ViewController: UIViewController {
  @IBOutlet weak var playButton: UIButton?
  @IBOutlet weak var networkSessionSwitch: UISwitch?
  @IBOutlet weak var otherAppsSwitch: UISwitch?
  var isPlaying: Bool = false
  var isOtherAppsEnabled: Bool = true
  var isNetworkSessionEnabled: Bool = true
  let sequencer = MIDISequencer(midiOutputName: "Baby Steps")

  override func viewDidLoad() {
    super.viewDidLoad()
    setupSequencer()
  }

  func setupSequencer() {
    sequencer.tempo = Tempo(
      timeSignature: TimeSignature(
        beats: 4,
        noteValue: .quarter),
      bpm: 80)

    let bassVolume = MIDISequencerStepVelocity.standard(100)
    let bass = MIDISequencerTrack(
      name: "Bass",
      midiChannel: 1,
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
      midiChannel: 2,
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
      midiChannel: 3,
      steps: arpeggiator.steps(
        position: 0,
        duration: 0.25,
        velocity: .random(min: 80, max: 120)))

    sequencer.addTrack(track: bass)
    sequencer.addTrack(track: chords)
    sequencer.addTrack(track: melody)
  }

  @IBAction func playButtonDidPress(sender: UIButton) {
    if isPlaying {
      sequencer.stop()
    } else {
      sequencer.play()
    }
    isPlaying = !isPlaying
    update()
  }

  @IBAction func otherAppsSwitchDidChange(switch: UISwitch) {
    isOtherAppsEnabled = `switch`.isOn
    update()
  }

  @IBAction func networkSessionSwitchDidChange(switch: UISwitch) {
    isNetworkSessionEnabled = `switch`.isOn
    update()
  }
  
  func update() {
    playButton?.setTitle(isPlaying ? "▢" : "▷", for: .normal)

  }
}

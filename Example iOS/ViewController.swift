//
//  ViewController.swift
//  Example iOS
//
//  Created by Cem Olcay on 26.10.2017.
//

import UIKit
import MIDISequencer
import AudioKit
import CoreMIDI
import MusicTheorySwift

class ViewController: UIViewController {
  @IBOutlet weak var playButton: UIButton?
  var isPlaying: Bool = false
  let sequencer = MIDISequencer(midiOutputName: "Baby Steps")

  override func viewDidLoad() {
    super.viewDidLoad()
    enableBackgroundMIDIPlaying()
    setupSequencer()
  }

  func enableBackgroundMIDIPlaying() {
    AudioKit.output = sequencer.midiCallbackInstrument
    AudioKit.start()
    try? AKSettings.setSession(
      category: .playback,
      with: .mixWithOthers)
  }

  func setupSequencer() {
    sequencer.tempo = Tempo(
      timeSignature: TimeSignature(
        beats: 4,
        noteValue: .quarter),
      bpm: 80)

    let bassVolume = MIDISequencerVelocity.standard(100)
    let bass = MIDISequencerTrack(
      name: "Bass",
      midiChannels: [0],
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

    let chordsVolume = MIDISequencerVelocity.standard(100)
    let chords = MIDISequencerTrack(
      name: "Chords",
      midiChannels: [1],
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
      midiChannels: [2],
      steps: arpeggiator.steps(
        position: 0,
        duration: 0.25,
        velocity: .random(min: 80, max: 120)))

    sequencer.add(track: bass)
    sequencer.add(track: chords)
    sequencer.add(track: melody)
  }

  @IBAction func playButtonDidPress(sender: UIButton) {
    if isPlaying {
      sequencer.stop()
    } else {
      sequencer.play()
    }
    isPlaying = !isPlaying
    playButton?.setTitle(isPlaying ? "▢" : "▷", for: .normal)
  }

  @IBAction func otherAppsSwitchDidChange(control: UISwitch) {
    if control.isOn {
      sequencer.midi.createVirtualOutputPort(name: sequencer.midiOutputName)
    } else {
      sequencer.midi.destroyVirtualPorts()
    }
  }

  @IBAction func networkSessionSwitchDidChange(control: UISwitch) {
    if control.isOn {
      sequencer.midi.openOutput("Session 1")
    } else {
      sequencer.midi.endpoints.removeValue(forKey: "Session 1")
    }
  }
}

//
//  MIDISequencer.swift
//  MIDISequencer
//
//  Created by Cem Olcay on 12/09/2017.
//
//

import Foundation
import AudioKit
import CoreMIDI
import MusicTheory

/// Sequencer's duration type.
public enum MIDISequencerDuration {
  /// Longest track's duration is the duration.
  case auto
  /// Number of bars in beat form.
  case bars(Double)
  /// Number of steps in beat form.
  case steps(Double)

  /// Calulates the duration of the sequencer.
  public func duration(of sequencer: MIDISequencer) -> Double {
    switch self {
    case .auto:
      return sequencer.tracks.map({ $0.duration }).sorted().last ?? 0
    case .bars(let barCount):
      return barCount * 4.0 // A bar has 4 steps.
    case .steps(let stepCount):
      return stepCount
    }
  }
}

// struct represeting last data received of each type

struct MIDIMonitorData {
    var noteOn = 0
    var velocity = 0
    var noteOff = 0
    var channel = 0
    var afterTouch = 0
    var afterTouchNoteNumber = 0
    var programChange = 0
    var pitchWheelValue = 0
    var controllerNumber = 0
    var controllerValue = 0

}



/// Sequencer with up to 16 tracks and multiple channels to broadcast MIDI sequences other apps.
public class MIDISequencer: ObservableObject, MIDIListener {
  
    @Published var data = MIDIMonitorData()

//    init() {}

    func start() {
        midi.openInput(name: "Bluetooth")
        midi.openInput()
        midi.addListener(self)
    }

    /// Stops playing the sequence.
    func stop() {
        midi.closeAllInputs()
//        sequencer?.stop()
//        sequencer = nil
    }
    
    

    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID? = nil,
                            offset: MIDITimeStamp = 0) {
        DispatchQueue.main.async {
            self.data.noteOn = Int(noteNumber)
            self.data.velocity = Int(velocity)
            self.data.channel = Int(channel)
        }
    }

    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID: MIDIUniqueID? = nil,
                             offset: MIDITimeStamp = 0) {
        DispatchQueue.main.async {
            self.data.noteOff = Int(noteNumber)
            self.data.channel = Int(channel)
        }
    }

    public func receivedMIDIController(_ controller: MIDIByte,
                                value: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        print("controller \(controller) \(value)")
        data.controllerNumber = Int(controller)
        data.controllerValue = Int(value)
        data.channel = Int(channel)
    }

    public func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        print("received after touch")
        data.afterTouch = Int(pressure)
        data.channel = Int(channel)
    }

    public func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        print("recv'd after touch \(noteNumber)")
        data.afterTouchNoteNumber = Int(noteNumber)
        data.afterTouch = Int(pressure)
        data.channel = Int(channel)
    }

    public func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        print("midi wheel \(pitchWheelValue)")
        data.pitchWheelValue = Int(pitchWheelValue)
        data.channel = Int(channel)
    }

    public func receivedMIDIProgramChange(_ program: MIDIByte,
                                   channel: MIDIChannel,
                                   portID: MIDIUniqueID? = nil,
                                   offset: MIDITimeStamp = 0) {
        print("PC")
        data.programChange = Int(program)
        data.channel = Int(channel)
    }

    public func receivedMIDISystemCommand(_ data: [MIDIByte],
                                   portID: MIDIUniqueID? = nil,
                                   offset: MIDITimeStamp = 0) {
//        print("sysex")
    }

    public func receivedMIDISetupChange() {
        // Do nothing
    }

    public func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        // Do nothing
    }

    public func receivedMIDINotification(notification: MIDINotification) {
        // Do nothing
    }

    
  /// Name of the sequencer.
  public private(set) var name: String
  /// Sequencer that sequences the `MIDISequencerStep`s in each `MIDISequencerTrack`.
  public private(set) var sequencer: AppleSequencer?
  /// Global MIDI referance object.
  public let midi = MIDI()
  /// All tracks in sequencer.
  public var tracks = [MIDISequencerTrack]()
  /// Tempo (BPM) and time signature value of sequencer.
  public var tempo = Tempo() { didSet{ sequencer?.setTempo(tempo.bpm) }}
  /// Duration of the sequencer. Defaults auto.
  public var duration: MIDISequencerDuration = .auto

  /// Returns true if sequencer is playing.
  public var isPlaying: Bool {
    return sequencer?.isPlaying ?? false
  }

  // MARK: Init

  /// Initilizes the sequencer with its name.
  ///
  /// - Parameter name: Name of sequencer that seen by other apps.
  public init(name: String) {
    self.name = name
    midi.createVirtualInputPort(name: "\(name) In")
    midi.createVirtualOutputPort(name: "\(name) Out")
    midi.addListener(self)
  }

  deinit {
    midi.destroyVirtualPorts()
    stop()
  }

  /// Creates an `AKSequencer` from `tracks`
  public func setupSequencer() {
    sequencer = AppleSequencer()
    
    for (index, track) in tracks.enumerated() {
      guard let newTrack = sequencer?.newTrack(track.name) else { continue }
      newTrack.setMIDIOutput(midi.virtualInput)

        for step in track.steps {
          let velocity = MIDIVelocity(step.velocity.velocity)
          let position = Duration(beats: step.position)
          let duration = Duration(beats: step.duration)

          for note in step.notes {
            let noteNumber = MIDINoteNumber(note.rawValue)

            newTrack.add(
              noteNumber: noteNumber,
              velocity: velocity,
              position: position,
              duration: duration,
              channel: MIDIChannel(index))
        }
      }
    }

    sequencer?.setTempo(tempo.bpm)
    sequencer?.setLength(Duration(beats: duration.duration(of: self)))
    sequencer?.enableLooping()
  }

  // MARK: Sequencing

  /// Plays the sequence from begining if any MIDI Output including virtual one setted up.
  public func play() {
    setupSequencer()
    sequencer?.play()
  }

  /// Setups sequencer on background thread and starts playing it.
  ///
  /// - Parameter completion: Fires when setup complete.
  public func playAsync(completion: (() -> Void)? = nil) {
    DispatchQueue.global(qos: .background).async {
      self.setupSequencer()
      DispatchQueue.main.async {
        self.sequencer?.play()
        completion?()
      }
    }
  }


  // MARK: Track Management

  /// Adds a track to optional index.
  ///
  /// - Parameters:
  ///   - track: Adding track.
  ///   - index: Optional index of adding track. Appends end of array if not defined. Defaults nil.
  public func add(track: MIDISequencerTrack) {
    if tracks.count < 16 {
      tracks.append(track)
    }
  }

  /// Removes a track.
  ///
  /// - Parameter track: Track going to be removed.
  /// - Returns: Returns result of removing operation in discardableResult form.
  @discardableResult public func remove(track: MIDISequencerTrack) -> Bool {
    guard let index = tracks.firstIndex(of: track) else { return false }
    tracks.remove(at: index)
    return true
  }

  /// Sets mute state of track to true.
  ///
  /// - Parameter on: Set mute or not.
  /// - Parameter track: Track going to be mute.
  /// - Returns: If track is not this sequenecer's, return false, else return true.
  @discardableResult public func mute(on: Bool, track: MIDISequencerTrack) -> Bool {
    guard let index = tracks.firstIndex(of: track) else { return false }
    tracks[index].isMute = on
    return true
  }

  /// Sets solo state of track to true.
  ///
  /// - Parameter on: Set solo or not.
  /// - Parameter track: Track going to be enable soloing.
  /// - Returns: If track is not this sequenecer's, return false, else return true.
  @discardableResult public func solo(on: Bool, track: MIDISequencerTrack) -> Bool {
    guard let index = tracks.firstIndex(of: track) else { return false }
    tracks[index].isSolo = on
    return true
  }

  // MARK: MIDIListener

  public func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
    guard sequencer?.isPlaying == true, tracks.indices.contains(Int(channel)) else {
      midi.sendNoteOffMessage(noteNumber: noteNumber, velocity: velocity)
      return
    }

    let track = tracks[Int(channel)]
    for trackChannel in track.midiChannels {
      midi.sendNoteOnMessage(
        noteNumber: noteNumber,
        velocity: track.isMute ? 0 : velocity,
        channel: MIDIChannel(trackChannel))
    }
  }

  public func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
    guard sequencer?.isPlaying == true,
      tracks.indices.contains(Int(channel))
      else { return }

    let track = tracks[Int(channel)]
    for trackChannel in track.midiChannels {
      midi.sendNoteOffMessage(
        noteNumber: noteNumber,
        velocity: velocity,
        channel: MIDIChannel(trackChannel))
    }
  }
}

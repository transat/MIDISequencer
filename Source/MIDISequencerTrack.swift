//
//  MIDISequencerTrack.swift
//  MIDISequencer
//
//  Created by Cem Olcay on 12/09/2017.
//
//

import Foundation
import AudioKit
import MusicTheorySwift

/// A track that has `MIDISequencerStep`s in `MIDISequencer`.
public class MIDISequencerTrack: Codable {
  /// Name of track.
  public var name: String
  /// MIDI Channel of track to send notes to.
  public var midiChannel: Int
  /// Steps in track.
  public var steps: [MIDISequencerStep]

  /// Duration of the track in form of beats.
  public var duration: Double {
    return steps.map({ $0.position + $0.duration }).sorted().last ?? 0
  }

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

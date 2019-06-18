source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/AudioKit/Specs.git'

def shared_pods
  pod 'AudioKit'
  pod 'MusicTheorySwift'
end

target 'MIDISequencer iOS' do
  platform :ios, '9.0'
  shared_pods
end

target 'MIDISequencer Mac' do
  platform :osx, '10.11'
  shared_pods
end

target 'Example Mac' do
  use_frameworks!
  platform :ios, '9.0'
  pod 'MIDISequencer', :path => '.'
end

target 'Example iOS' do
  use_frameworks!
  platform :osx, '10.11'
  pod 'MIDISequencer', :path => '.'
end

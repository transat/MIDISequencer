source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/AudioKit/Specs.git'

def shared_pods
  pod 'AudioKit'
  pod 'MusicTheorySwift'
end

target 'MIDISequencer iOS' do
  shared_pods
end

target 'MIDISequencer Mac' do
  shared_pods
end

target 'Example Mac' do
  use_frameworks!
  pod 'MIDISequencer', :path => '.'
end

target 'Example iOS' do
  use_frameworks!
  pod 'MIDISequencer', :path => '.'
end

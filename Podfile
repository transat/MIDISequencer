# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def shared_pods
  use_frameworks!
  pod 'MusicTheorySwift'
  pod 'AudioKit'
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

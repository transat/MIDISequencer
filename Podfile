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

pre_install do |installer|
  # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
  Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end

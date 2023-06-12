source 'https://github.com/CocoaPods/Specs.git'
workspace 'RudderSingular.xcworkspace'
use_frameworks!
inhibit_all_warnings!
platform :ios, '13.0'


target 'RudderSingular' do
    project 'RudderSingular.xcodeproj'
    pod 'Rudder', '~> 2.0'
    pod 'Singular-SDK', '11.0.4'
end

target 'SampleAppObjC' do
    project 'Examples/SampleAppObjC/SampleAppObjC.xcodeproj'
    pod 'RudderSingular', :path => '.'
end

target 'SampleAppSwift' do
    project 'Examples/SampleAppSwift/SampleAppSwift.xcodeproj'
    pod 'RudderSingular', :path => '.'
end

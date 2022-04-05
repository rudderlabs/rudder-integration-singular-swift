workspace 'RudderSingular.xcworkspace'
use_frameworks!
inhibit_all_warnings!
platform :ios, '13.0'

def shared_pods
    pod 'RudderStack', :path => '~/Documents/Rudder/rudder-sdk-swift/'
end

target 'RudderSingular' do
    project 'RudderSingular.xcodeproj'
    shared_pods
    pod 'Singular-SDK', '11.0.4'
end

target 'SampleAppObjC' do
    project 'Examples/SampleAppObjC/SampleAppObjC.xcodeproj'
    shared_pods
    pod 'RudderSingular', :path => '.'
end

target 'SampleAppSwift' do
    project 'Examples/SampleAppSwift/SampleAppSwift.xcodeproj'
    shared_pods
    pod 'RudderSingular', :path => '.'
end
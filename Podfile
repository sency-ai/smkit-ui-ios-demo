platform :ios, '15.0'

source 'https://bitbucket.org/sencyai/ios_sdks_release.git'
source 'https://github.com/CocoaPods/Specs.git'

workspace 'SMKitUIDemo.xcworkspace'

target 'SMKitUIDemoApp' do
  use_frameworks!
  if ENV['SMKIT_LOCAL_SDK_ROOT']
    require File.join(ENV.fetch('SMKIT_LOCAL_SDK_ROOT'), 'scripts', 'local-sdk-pods')
    SMKitLocalPods.install(self, root: ENV.fetch('SMKIT_LOCAL_SDK_ROOT'), include_ui: true, version: '2.7.0')
  else
    pod 'SMKitUI', '= 2.7.1'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end

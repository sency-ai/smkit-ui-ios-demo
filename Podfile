source 'https://bitbucket.org/sencyai/ios_sdks_release.git'
source 'https://github.com/CocoaPods/Specs.git'

workspace 'SMKitUIDemo.xcworkspace'

target 'SMKitUIDemoApp' do
  use_frameworks!
  pod 'SMKitUI', '0.3.4'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.5'
    end
  end
end

# [smkit-ui-ios-demo](https://github.com/sency-ai/smkit-sdk)

## Table of contents
1. [ Installation ](#inst)
2. [ Setup ](#setup)
3. [ Configure ](#conf)
4. [ Start ](#start)
5. [ Excluding Feedback ](#feedback)
6. [ Data ](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/DataTypes.md)


## 1. Installation <a name="inst"></a>

### Cocoapods
*Latest pod version: SMKitUI '0.3.0'*
```ruby
// [1] add the source to the top of your Podfile.
source 'https://bitbucket.org/sencyai/ios_sdks_release.git'
source 'https://github.com/CocoaPods/Specs.git'

// [2] add the pod to your target
target 'YourApp' do
  use_frameworks!
  pod 'SMKitUI'
end

// [3] add post_install hooks
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.5'
    end
  end
end
```

Run ```pod install --repo-update```


### SPM

In your Package Dependencies add this url https://bitbucket.org/sencyai/smkit_ui_package and then press Add package

Latest version: smkit_ui_package '0.3.0'

## 2. Setup <a name="setup"></a>
Add camera permission request to `Info.plist`
```Xml
<key>NSCameraUsageDescription</key>
<string>Camera access is needed</string>
```

## 3. Configure <a name="conf"></a>
```Swift
SMKitUIModel.configure(authKey: "YOUR_KEY") {
    // The configuration was successful
    // Your Code
} onFailure: { error in
    // The configuration failed with error
    // Your Code
}
```
To reduce wait time we recommend to call `configure` on app launch.

**⚠️ SMKitUI will not work if you don't first call configure.**

## 4. Start <a name="start"></a>

- [Start Assessment](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/Assessment.md)

- [Start Workout](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/Workout.md)

- [Build Your Own Assessment](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/CustomizedAssessment.md)

## 5. Excluding Feedback <a name="feedback"></a>

You have the ability to exclude specific exercise feedbacks.
To do this, follow the example below:

```swift
// Before starting any workout or assessment, call one of these functions:

// The feedbacks to exclude
let excludedFeedbacks:[FormFeedbackTypeBr] = [.pushupKneesOnFloor]

// Exclude the feedback from both data and UI
SMKitUIModel.setExcludedFeedbacks(excludedFeedbacks: excludedFeedbacks)

// Exclude the feedback from the UI only
SMKitUIModel.setFeedbacksUIToExclude(feedbacksUIToExclude: excludedFeedbacks)

```

--------

Having issues? [Contact us](mailto:support@sency.ai) and let us know what the problem is.

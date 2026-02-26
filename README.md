# [smkit-ui-ios-demo](https://github.com/sency-ai/smkit-sdk)

## Table of contents
1. [ Installation ](#inst)
2. [ Setup ](#setup)
3. [ Configure ](#conf)
4. [ Start ](#start)
5. [ Excluding Feedback ](#feedback)
6. [ Modifying Feedback Parameters ](#modify)
7. [ Setting Text Language ](#language)
8. [ Setting Pause Types ](#pause)
9. [ Advanced Configuration (1.5.0) ](#advanced)
10. [  MCP Server Access ](#mcp)
10. [ Data ](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/DataTypes.md)


## 1. Installation <a name="inst"></a>

### Cocoapods
*Latest pod version: SMKitUI '1.5.0'*

**New in 1.5.0:** Multiple new exercises, pause exercise by hovering palm on the X icon, intelligence rest and exercise modifications, external audio mixing control, accurate pose estimation mode, and a full skeleton visualisation customization system.
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

Latest version: smkit_ui_package '0.3.3'

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

## 6. Modifying Feedback Parameters <a name="modify"></a>

You have the ability to modify specific feedback parameters for exercises.
This allows you to customize the thresholds and ranges for feedback detection.

To modify feedback parameters, use the following example:

```swift
let modifications: [String: Any] = [
    "Crunches": [
        // Feedback/parameter name: [parameter values]
        "DepthCrunchesShallowDepth": ["low": 0.1, "high": 0.9],
        // Add more parameters as needed
    ]
]
```

**Note:** We will release our feedbacks catalog soon. Feel free to reach us for assistant in applying modifications.

## 7. Setting Text Language <a name="language"></a>

You can change the text language (default is English).
To do this, follow the example below:

```swift
let lang = SencySupportedLanguage.English

SMKitUIModel.setSessionLanguage(languge: lang)
```

## 8. Setting Pause Types <a name="pause"></a>
In SMKitUI you have the ability to choose what buttons will appear on the pause alert to do so you need to call setAllowedPauseTypes before the session starts like so:

```swift
let pauseTypes:[PauseAlertType] = [.StartOver, .Skip, .Quit]
try SMKitUIModel.setAllowedPauseTypes(types: pauseTypes)
```

### `PauseAlertType`
| Type                | Description                           |
|---------------------|---------------------------------------|
| Resume              | will reasume the workout              |
| StartOver           | will start over the exercise          |
| Skip                | will skip the exercise                |
| Quit                | will quit the Assessmet               |

## 9. Advanced Configuration (1.5.0) <a name="advanced"></a>

These properties must be set **before** starting a session.

### Intelligence / Fatigue Detection
```swift
SMKitUIModel.enableIntelligenceRest = true  // Enable in-session rest suggestions based on fatigue
```

### Audio Mixing
```swift
SMKitUIModel.allowAudioMixing = true           // Allow external apps (music, podcasts) to keep playing
SMKitUIModel.showExternalAudioControl = true   // Show in-session audio source picker to the user
```

### Accurate Pose Estimation
```swift
SMKitUIModel.accuratePoseEstimation = true  // Higher accuracy, higher CPU cost
```

### Skeleton Visualisation
Use a preset for quick theming:
```swift
SMKitUIModel.skeletonPreset = .neonGlow   // One of 26 built-in presets
```

Or fine-tune individual properties:
```swift
SMKitUIModel.skeletonHidden = false
SMKitUIModel.skeletonConnectionStyle = .solid    // none, dotted, dashed, solid, longDashed, thinDots, dotDashed, rounded
SMKitUIModel.skeletonJointShape = .circle        // circle, square, triangle, diamond, star, hexagon
SMKitUIModel.skeletonDotsOpacity = 1.0
SMKitUIModel.skeletonConnectionsOpacity = 0.8
SMKitUIModel.skeletonDotsGlow = 0.5
SMKitUIModel.skeletonConnectionsGlow = 0.3
SMKitUIModel.skeletonLineWidthScale = 1.0
SMKitUIModel.skeletonOutlineScale = 1.0
SMKitUIModel.skeletonSoftness = 0.0
SMKitUIModel.skeletonAnimationDuration = 0.15
SMKitUIModel.skeletonDotsInnerColorOption = .white
SMKitUIModel.skeletonDotsOuterColorOption = .cyan
SMKitUIModel.skeletonConnectionsInnerColorOption = .white
SMKitUIModel.skeletonConnectionsOuterColorOption = .cyan
```

## 10. MCP Server Access <a name="mcp"></a>

- Cursor: add the server definition below to `~/.cursor/mcp.json` and reload Cursor.
[Contact us](mailto:support@sency.ai) to receive your API key.

```json
{
  "mcpServers": {
    "smkitui": {
      "type": "streamable-http",
      "url": "https://sency-mcp-production.up.railway.app/mcp",
      "headers": {
        "X-API-Key": "Your-API-Key"
      }
    }
  }
}
```

- CLI: run 
```npx @modelcontextprotocol/cli client http --url https://sency-mcp-production.up.railway.app/mcp --header "X-API-Key: Your-API-Key"```.

--------

Having issues? [Contact us](mailto:support@sency.ai) and let us know what the problem is.

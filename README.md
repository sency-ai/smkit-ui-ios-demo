# [smkit-ui-ios-demo](https://github.com/sency-ai/smkit-sdk)

## Table of contents
1. [ Installation ](#inst)
2. [ Setup ](#setup)
3. [ Configure ](#conf)
4. [ Start ](#start)
5. [ Native Demo Features ](#demo-features)
6. [ Model and Asset Delivery ](#asset-delivery)
7. [ Excluding Feedback ](#feedback)
8. [ Modifying Feedback Parameters ](#modify)
9. [ Setting Text Language ](#language)
10. [ Setting Pause Types ](#pause)
11. [ Advanced Configuration ](#advanced)
12. [ Exercise and Workout Options ](#exercise-options)
13. [ MCP Server Access ](#mcp)
14. [ Data ](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/DataTypes.md)


## 1. Installation <a name="inst"></a>

### Cocoapods
*Demo pod version: SMKitUI '2.3.6'*

This native demo is pinned to SMKitUI 2.3.6 and exposes the relevant SDK controls through the in-app Settings screen.

Support: iOS 15 or later; officially validated on iPhone X and newer. This device policy documents the validated support matrix; the SDK does not add a runtime model gate.

```ruby
// [1] add the source to the top of your Podfile.
platform :ios, '15.0'

source 'https://bitbucket.org/sencyai/ios_sdks_release.git'
source 'https://github.com/CocoaPods/Specs.git'

// [2] add the pod to your target
target 'YourApp' do
  use_frameworks!
  pod 'SMKitUI', '2.3.6'
end

// [3] add post_install hooks
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
```

Run ```pod install --repo-update```


### SPM

In your Package Dependencies add this url https://bitbucket.org/sencyai/smkit_ui_package and then press Add package

Current SPM package version: smkit_ui_package '2.3.6'

## 2. Setup <a name="setup"></a>
Add camera permission request to `Info.plist`
```Xml
<key>NSCameraUsageDescription</key>
<string>Camera access is needed</string>
```

## 3. Configure <a name="conf"></a>
```Swift
SMKitUIModel.configure(
    authKey: "YOUR_KEY",
    modelDownloadPolicy: .waitForRemoteModelsThenFallback
) {
    // The configuration was successful
    // Your Code
} onFailure: { error in
    // The configuration failed with error
    // Your Code
}
```
To reduce wait time we recommend to call `configure` on app launch.

**⚠️ SMKitUI will not work if you don't first call configure.**

The native demo app reads its auth key from `SMKitUIDemoApp/Config/AuthKey.local.xcconfig`, which is intentionally ignored by Git:

```xcconfig
SMKIT_UI_AUTH_KEY = YOUR_KEY
```

## 4. Start <a name="start"></a>

- [Start Assessment](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/Assessment.md)

- [Start Workout](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/Workout.md)

- [Build Your Own Assessment](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/CustomizedAssessment.md)

## 5. Native Demo Features <a name="demo-features"></a>

The app is a working catalog of the main SMKitUI flows, not only a collection of code snippets:

- **Build Workout** loads the supported SDK movements and lets you add, reorder, and configure exercises before starting.
- **Build Assessment** creates a custom assessment with reps, time, or ROM scoring, optional target-reps progress, and a rep-timer workout mode.
- **Start Built-In Assessment** lets you choose a Fitness, Body 360, Cardio, Strength, or Custom assessment.
- **Guidance Mode** lists the supported guided movements and starts the selected movement with guidance enabled.
- **UI Settings** persists appearance, audio, calibration, pause, and session-behavior choices between launches.

## 6. Model and Asset Delivery <a name="asset-delivery"></a>

SMKitUI 2.3.6 downloads models and required SDK assets from the server during configuration and before a relevant session begins. The SDK does not include bundled fallback models. Keep the device online for the first configuration and asset download; a valid, previously downloaded cache can be used offline later.

`SMModelDownloadPolicy` controls how configuration uses the downloaded cache. Its fallback is a previously server-downloaded cache only, never an embedded model.

## 7. Excluding Feedback <a name="feedback"></a>

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

## 8. Modifying Feedback Parameters <a name="modify"></a>

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

## 9. Setting Text Language <a name="language"></a>

You can change the text language (default is English).
To do this, follow the example below:

```swift
let lang = SencySupportedLanguage.English

SMKitUIModel.setSessionLanguage(language: lang)
SMKitUIModel.setPhoneCalibrationLanguage(language: lang)
```

## 10. Setting Pause Types <a name="pause"></a>
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
| Rest                | will show the rest action             |
| Switch              | will show the switch action           |

## 11. Advanced Configuration <a name="advanced"></a>

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

### Theme and Phone Calibration
```swift
SMKitUIModel.colorTheme = .green

try SMKitUIModel.startWorkout(
    viewController: self,
    workout: workout,
    delegate: self,
    showPhoneCalibration: false
)
```

`showPhoneCalibration` can also be passed to built-in and custom assessment starts. The demo exposes this choice in **UI Settings**.

### Watch Companion and Heart-Rate Rest
```swift
SMKitUIModel.enableWatchCompanion = true
SMKitUIModel.enableHeartRateRest = true
SMKitUIModel.heartRateRestThreshold = 140
```

Enable these only when your app has the required Apple Watch/heart-rate integration. The demo exposes the SDK switches, but does not include a Watch app target.

### Assessment End and Counter Preferences
```swift
// End an assessment exercise when its configured target is reached, or when its timer expires.
SMKitUIModel.setEndExercisePreferences(endExercisePreferences: .TargetBased)

// Count only reps performed without form feedback.
SMKitUIModel.setCounterPreferences(counterPreferences: .PerfectOnly)
```

Use target-based ending only when the assessment has the relevant `ScoringParams` target: `targetReps` for dynamic exercises or `targetTime` for static exercises.

### Session Behavior
```swift
SMKitUIModel.playPhoneCalibrationAudio = true
SMKitUIModel.playBodyCalibrationAudio = true
SMKitUIModel.startTimerOnFirstActivity = true
SMKitUIModel.enablePhoneMovementCountPrevention = true
SMKitUIModel.enableVariationMismatchFeedback = true
SMKitUIModel.enableButtonTutorial = true
SMKitUIModel.workoutContinuationTimerDuration = 8
```

### Instruction Video Cycling
Control how the instruction video transitions after the instruction phase ends:
```swift
// Default mode: video shrinks to small corner immediately
SMKitUIModel.instructionVideoConfig = SMKit.InstructionVideoConfig()

// Medium cycle mode: video stays at 75% size while exercise video loops N times, then shrinks
SMKitUIModel.instructionVideoConfig = SMKit.InstructionVideoConfig(
    displayMode: .mediumCycle,
    mediumSizeCycles: 3  // Video stays medium-sized for 3 loops (range 1-5)
)
```

| Mode | Behavior |
|------|----------|
| `.default` | Instruction video immediately shrinks to small corner (original behavior) |
| `.mediumCycle` | Instruction video transitions to 75% size, stays medium while exercise loops N times, then shrinks |

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

## 12. Exercise and Workout Options <a name="exercise-options"></a>

The demo app's Build Workout flow starts empty, loads supported SDK movements from `SMKitUIModel.getSupportedMovements()`, filters out Rowing, and lets you add, remove, reorder, configure, and start exercises.

- **Build Workout**: a native builder for selecting supported exercises and setting per-exercise duration, phone position, guidance mode, wide-angle camera, short intro, countdown, rep audio, adaptive ROM, and optional stretch-set configuration.

### Built-In UI Defaults
Set `uiElements` to `nil` to use the SDK defaults from `ExerciseUIDefaults`.

```swift
let exercise = SMExercise(
    name: "Quick Feet",
    exerciseIntro: nil,
    totalSeconds: 20,
    videoInstruction: "QuickFeet",
    uiElements: nil,
    detector: "QuickFeet",
    exerciseClosure: nil
)
```

### Quick Motion
```swift
let quickFeet = SMExercise(
    name: "Quick Feet",
    exerciseIntro: nil,
    totalSeconds: 20,
    videoInstruction: "QuickFeet",
    detector: "QuickFeet",
    exerciseClosure: nil,
    quickMotionParams: QuickMotionParams(validityWindow: 1.5, checkInterval: 0.15)
)
```

### Per-Exercise Audio Controls
```swift
let highKnees = SMExercise(
    name: "High Knees",
    exerciseIntro: nil,
    totalSeconds: 30,
    videoInstruction: "HighKnees",
    detector: "HighKnees",
    exerciseClosure: nil,
    playPreExerciseCountdown: true,
    playRepMilestoneVoice: true,
    repMilestoneInterval: 5,
    playSoundOnEachRep: true
)
```

### Adaptive ROM
```swift
let squat = SMExercise(
    name: "Squat Regular",
    exerciseIntro: nil,
    totalSeconds: 30,
    videoInstruction: "SquatRegular",
    detector: "SquatRegular",
    exerciseClosure: nil
)
squat.adaptiveRomFeedbackEnabled = true
squat.adaptiveRomWarmupReps = 2
```

### Guidance Video Segments
```swift
let sideBend = SMExercise(
    name: "Standing Side Bend Right",
    exerciseIntro: nil,
    totalSeconds: 25,
    videoInstruction: "StandingSideBendRight",
    detector: "StandingSideBendRight",
    exerciseClosure: nil,
    guidanceMode: true
)
sideBend.guidanceVideoSegments = [
    "phase1_orient": .freeze(at: 0),
    "phase2_setup": .play(from: 0, to: 3),
    "phase4_action": .play(from: 3, to: 8),
    "phase5_hold": .freeze(at: 8)
]
```

### Stretch Sets
```swift
let stretch = SMExercise(
    name: "Downward Dog Prayer Stretch Set",
    exerciseIntro: nil,
    totalSeconds: 40,
    videoInstruction: "DownwardDogPrayerStretch",
    detector: "DownwardDogPrayerStretch",
    exerciseClosure: nil,
    stretchSetConfig: SMStretchSetConfig(
        enabled: true,
        repetitions: 3,
        secondsPerStretch: 8,
        restSecondsBetweenStretches: 4
    )
)
```

### Workout Continuation
```swift
let continuation = SMWorkoutContinuation(
    introSoundKey: nil,
    interactionUnlockSoundKey: "",
    exercises: [
        SMExercise(name: "Jumping Jacks", exerciseIntro: nil, totalSeconds: 20, videoInstruction: "JumpingJacks", detector: "JumpingJacks", exerciseClosure: nil)
    ]
)

let workout = SMWorkout(
    id: "",
    name: "Built Workout",
    workoutIntro: nil,
    soundtrack: nil,
    exercises: [stretch],
    workoutClosure: nil,
    continuation: continuation
)
```

## 13. MCP Server Access <a name="mcp"></a>

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

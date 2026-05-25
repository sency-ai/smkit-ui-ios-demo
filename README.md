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
9. [ Advanced Configuration (1.9.1) ](#advanced)
10. [ Exercise and Workout Options ](#exercise-options)
11. [ MCP Server Access ](#mcp)
12. [ Data ](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/DataTypes.md)


## 1. Installation <a name="inst"></a>

### Cocoapods
*Demo pod version: SMKitUI '1.9.1'*

This native demo is pinned to SMKitUI 1.9.1 and exposes the relevant SDK controls through the in-app Settings screen.

```ruby
// [1] add the source to the top of your Podfile.
source 'https://bitbucket.org/sencyai/ios_sdks_release.git'
source 'https://github.com/CocoaPods/Specs.git'

// [2] add the pod to your target
target 'YourApp' do
  use_frameworks!
  pod 'SMKitUI', '1.9.1'
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

Latest demo-aligned version: smkit_ui_package '1.9.1'

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

The native demo app reads its auth key from `SMKitUIDemoApp/Config/AuthKey.local.xcconfig`, which is intentionally ignored by Git:

```xcconfig
SMKIT_UI_AUTH_KEY = YOUR_KEY
```

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

## 7. Setting Text Language <a name="language"></a>

You can change the text language (default is English).
To do this, follow the example below:

```swift
let lang = SencySupportedLanguage.English

SMKitUIModel.setSessionLanguage(language: lang)
SMKitUIModel.setPhoneCalibrationLanguage(language: lang)
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

## 9. Advanced Configuration (1.9.1) <a name="advanced"></a>

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

## 10. Exercise and Workout Options <a name="exercise-options"></a>

The demo app's Build Workout flow starts empty, loads supported SDK movements from `SMKitUIModel.getSupportedMovements()`, filters out Rowing, and lets you add, remove, reorder, configure, and start exercises.

- **Build Workout**: a native builder for selecting supported exercises and setting per-exercise duration, phone position, guidance mode, intro, countdown, rep audio, adaptive ROM, and optional stretch-set configuration.

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

## 11. MCP Server Access <a name="mcp"></a>

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

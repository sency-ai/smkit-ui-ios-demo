# [smkit-ui-ios-demo](https://github.com/sency-ai/smkit-sdk)

## Table of contents
1. [ Installation ](#inst)
2. [ Setup ](#setup)
3. [ Configure ](#conf)
4. [ Start ](#start)
5. [ Delegates and Callbacks ](#delegates)
6. [ Native Demo Features ](#demo-features)
7. [ Model and Asset Delivery ](#asset-delivery)
8. [ Excluding Feedback ](#feedback)
9. [ Modifying Feedback Parameters ](#modify)
10. [ Setting Text Language ](#language)
11. [ Setting Pause Types ](#pause)
12. [ Audio and Feedback ](#audio)
13. [ Heart Rate and Apple Watch ](#heart-rate)
14. [ Calibration and Visuals ](#visuals)
15. [ Guidance Mode ](#guidance)
16. [ Advanced Configuration ](#advanced)
17. [ Exercise and Workout Options ](#exercise-options)
18. [ Exercise Combinations ](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/Combinations.md)
19. [ MCP Server Access ](#mcp)
20. [ Data ](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/DataTypes.md)


## 1. Installation <a name="inst"></a>

### CocoaPods
*Demo pod version: SMKitUI '2.7.3'*

This native demo targets SMKitUI 2.7.3 and exposes the relevant SDK controls through the in-app Settings screen.

Support: iOS 15 or later; officially validated on iPhone X and newer. This device policy documents the validated support matrix; the SDK does not add a runtime model gate.

```ruby
# [1] add the source to the top of your Podfile.
platform :ios, '15.0'

source 'https://bitbucket.org/sencyai/ios_sdks_release.git'
source 'https://github.com/CocoaPods/Specs.git'

# [2] add the pod to your target
target 'YourApp' do
  use_frameworks!
  pod 'SMKitUI', '= 2.7.3'
end

# [3] add post_install hooks
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

Run ```pod install --repo-update``` to resolve SMKitUI, SMKit, and SMBase 2.7.3 from the release CocoaPods source.


### SPM

In your Package Dependencies add this url https://bitbucket.org/sencyai/smkit_ui_package and then press Add package

SPM package version: smkit_ui_package '2.7.1'

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

### Configure parameters

All parameters except `authKey`, `onSuccess`, and `onFailure` are optional.

| Parameter | Default | Description |
|-----------|---------|-------------|
| `authKey` | — | Your Sency auth key. |
| `customerCode` | `nil` | Your customer code, when Sency has provided one. It selects your customer configuration and customer assets. |
| `modelDownloadPolicy` | `.waitForRemoteModelsThenFallback` | How configuration uses the downloaded model cache (see below). |
| `language` | `.English` | Voice-feedback language used for the audio downloaded during configuration. |
| `voiceFeedbackVoice` | `"male_1"` | Voice for English and Mandarin feedback: `"male_1"` or `"female_1"`. Hebrew is unaffected. |
| `mobilityFlowVoice` | `"female_1"` | Voice used inside Mobility Flow exercises: `"male_1"` or `"female_1"`. |

```swift
SMKitUIModel.configure(
    authKey: "YOUR_KEY",
    customerCode: "YOUR_CUSTOMER_CODE",
    modelDownloadPolicy: .waitForRemoteModelsThenFallback,
    language: .English,
    voiceFeedbackVoice: "female_1",
    mobilityFlowVoice: "female_1"
) {
    // Ready
} onFailure: { error in
    // Handle the error
}
```

### `SMModelDownloadPolicy`

| Policy | Behavior |
|--------|----------|
| `.waitForRemoteModelsThenFallback` | Default. Configure completes once the metadata is received and downloads models in the background; a workout start waits for the current server models. A verified, matching cache from an earlier download is used as the fallback. |
| `.immediateFallback` | Starts right away when the required models are already cached from an earlier download, and refreshes them in the background. |

The fallback is always a cache previously downloaded from the server; the SDK does not include bundled models.

### Model preloading

After `configure` succeeds, SMKitUI prepares its pose models in the background so the first session starts faster.

```swift
// Set before configure to manage preparation yourself.
SMKitUIModel.automaticallyPreloadModels = false

// Later, when it suits your app (non-blocking and safe to call repeatedly):
SMKitUIModel.preloadModelsInBackground()
```

### Pre-downloading workout assets

Download the instruction videos and audio for a workout before starting it, for example to prepare an offline session. Call `configure` first.

```swift
// By detector names:
let task = SMKitUIModel.predownloadWorkoutAssets(
    detectors: ["SquatRegular", "HighKnees"],
    progress: { downloadedBytes, totalBytes in
        // Update your progress UI
    },
    completion: { result in
        switch result {
        case .success(true):  print("Workout assets are ready")
        case .success(false): print("Configure the SDK successfully before downloading")
        case .failure(let error): print(error.localizedDescription)
        }
    }
)

// Or for a complete workout (includes its continuation exercises):
SMKitUIModel.predownloadWorkoutAssets(workout: workout, progress: { _, _ in }) { result in }

// Cancel if needed. Files that finished downloading stay in the cache.
task.cancel()
```

For a built-in assessment, pass its type with `assessment:`, and pass `mobilityFlow: true` when the detectors are used in a Mobility Flow exercise. See [Model and Asset Delivery](#asset-delivery) for the offline flow.

### Customer assets

When you configure with a `customerCode`, files that Sency has set up for your account can be fetched by identifier:

```swift
// Returns the local URL when the asset has already been downloaded.
let url = SMKitUIModel.customerAssetURL(for: "ASSET_ID")

// Downloads the asset if needed. The completion receives nil when it is unavailable.
SMKitUIModel.requestCustomerAsset(for: "ASSET_ID") { url in
}
```

### Diagnostics

Receive SDK diagnostic events in your app, for example to forward them to your own logging. The SDK itself sends no diagnostic events over the network.

```swift
SMKitUIModel.diagnosticsHandler = { event in
    // event.name, event.category, event.severity, event.message,
    // event.errorDomain, event.errorCode, event.properties, event.timestamp
    print("[\(event.severity.rawValue)] \(event.category.rawValue): \(event.message)")
}
```

Release builds report instruction-video playback and Mobility Flow soundtrack results.

## 4. Start <a name="start"></a>

- [Start Assessment](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/Assessment.md)

- [Start Workout](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/Workout.md)

- [Build Your Own Assessment](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/CustomizedAssessment.md)

All start functions accept `showPhoneCalibration:` (default `true`) and `modifications:` (see [Modifying Feedback Parameters](#modify)). Starting a session while another is running throws `SMWorkoutError.WorkoutSessionIsAlreadyRunning`.

### Start a Program Workout
**startWorkoutFromProgram** starts a workout from a Sency program, selected by `WorkoutConfig`:

```swift
let workoutConfig = WorkoutConfig(
    week: 1,                          // The program week
    bodyZone: .FullBody,              // .UpperBody, .LowerBody, .FullBody
    difficultyLevel: .HighDifficulty, // .LowDifficulty, .MidDifficulty, .HighDifficulty
    workoutDuration: .Short,          // .Short, .Long
    language: .English,
    programID: "YOUR_PROGRAM_ID",
    phonePosition: .Floor,            // .Floor or .Elevated
    shortIntro: false                 // Use short exercise intros
)

SMKitUIModel.startWorkoutFromProgram(viewController: self, workoutConfig: workoutConfig, delegate: self) { error in
    print(error)
}
```

### Controlling a running session

```swift
try SMKitUIModel.pauseSDK()     // Pause the active session
try SMKitUIModel.resumeSDK()    // Resume it

// Skip the current exercise (for example from your own remote control).
// Returns true when an active workout accepted the request.
let skipped = SMKitUIModel.skipCurrentExercise()

// Close SMKitUI.
SMKitUIModel.exitSDK()

// Or close it and get notified on the main thread once teardown completes.
SMKitUIModel.exitSDK { result in
    switch result {
    case .success: break // Camera stopped, UI dismissed, session reset
    case .failure(let error): print(error)
    }
}

// Whether an SDK workout is currently active.
let running = SMKitUIModel.isWorkoutRunning
```

You can also observe `Notification.Name.smKitUIWorkoutDidStart` and `.smKitUIWorkoutDidEnd`.

In a Mobility Flow exercise, `skipCurrentExercise()` advances to the next block; skipping the last block finishes the exercise.

### Exercise discovery

```swift
// All movements supported by your configuration.
let movements = SMKitUIModel.getSupportedMovements() ?? []

// The type of an exercise: .Dynamic, .Static, .Mobility, .BodyAssessment, ...
let type = try SMKitUIModel.getExerciseType(type: "SquatRegular")

// The instruction video for a detector, as a local file URL (nil when unavailable).
SMKitUIModel.loadInstructionVideo(for: "SquatRegular") { url in }

// A thumbnail of that video, already oriented as the SDK plays it. Don't mirror it again.
SMKitUIModel.loadInstructionVideoThumbnail(for: "SquatRegular") { image in }
```

Both loaders call their completion on the main thread. Call them after `configure` has started.

### Errors

`SMWorkoutError` is thrown by the start functions and by `setAllowedPauseTypes`. Its `errorDescription` contains a readable message. Common cases:

| Case | Meaning |
|------|---------|
| `WorkoutSessionIsAlreadyRunning` | A session is already active. |
| `InvalidSMWorkout(String)` / `InvaildSMExercise(String)` | The workout or one of its exercises is invalid; the string explains why. |
| `AssessmentMissingScoringParams` | A custom assessment exercise has no `ScoringParams`. |
| `PauseAlertTypeCantByEmpty` | `setAllowedPauseTypes` was called with an empty list. |
| `UnableToResumeExercise` | `resumeSDK()` was called when there is nothing to resume. |

## 5. Delegates and Callbacks <a name="delegates"></a>

### `SMKitUIWorkoutDelegate`

Required for every session:

| Method | Called when |
|--------|-------------|
| `handleWorkoutErrors(error:)` | A runtime error happens. |
| `workoutDidFinish()` | The session finished. Call `SMKitUIModel.exitSDK()` to close SMKitUI. |
| `didExitWorkout()` | The user quit the session. Call `SMKitUIModel.exitSDK()` to close SMKitUI. |
| `exerciseDidFinish(data:)` | An exercise finished, with its `ExerciseData`. |
| `didReceiveSummaryData(data:)` | The session summary (`WorkoutSummaryData`) is available. |

Optional, with default empty implementations:

| Method | Called when |
|--------|-------------|
| `workoutContinuationPromptDidAppear()` | The [workout continuation](#workout-continuation) prompt is shown. |
| `workoutContinuationUserDidChoose(continueWorkout:)` | The user chose whether to continue. |

### Optional companion protocols

Adopt these on the same object you pass as `delegate:`. They are called on the main thread.

```swift
extension ViewController: SMKitUIExerciseLifecycleDelegate {
    // The next exercise is about to start.
    // Mobility Flow calls this for each block; data.totalTime is the block's hold time.
    func exerciseWillStart(data: ExerciseData) {
    }
}

extension ViewController: SMKitUIWorkoutPreparationDelegate {
    // Preparation finished and the session moved on to body calibration.
    func workoutPreparationDidFinish() {
    }

    // The user cancelled during preparation. Called before didExitWorkout().
    func workoutPreparationDidCancel() {
    }
}
```

### Recovering interrupted sessions

If a session can't continue (for example the app was terminated), the SDK keeps a partial result. Read it on the next launch, after `configure`:

```swift
SMKitUIModel.consumeRecoveredSessionSummaries { recovered in
    for item in recovered {
        let native = item.nativeSummary      // faultCode, recoveredAfterRelaunch, recoveredAt, sessionResult
        let summary = item.workoutSummary    // WorkoutSummaryData, when UI data was saved; otherwise nil
    }
}
```

Each recovered result is delivered once. The completion runs on the main thread.

## 6. Native Demo Features <a name="demo-features"></a>

The app is a working catalog of the main SMKitUI flows, not only a collection of code snippets. All demo settings are stored in `DemoSettingsStore` and applied to `SMKitUIModel` (`applyToSDK()`) at launch and before every session.

- **Build Workout** loads the movements returned by `SMKitUIModel.getSupportedMovements()` (Rowing is filtered out), groups them by `getExerciseType(type:)`, and lets you add, remove, reorder, and configure exercises. For each exercise you can set duration, phone position, guidance mode, wide-angle camera, short intro, pre-exercise countdown, rep milestone voice and interval, rep sound, adaptive ROM, and a stretch set. Continuation exercises can be added when **Workout continuation** is on in UI Settings. The **Download** button calls `predownloadWorkoutAssets(detectors:progress:completion:)` for the selected detectors so you can test an offline start.
- **Build Assessment** creates an `SMWorkoutAssessment`. Each exercise is scored by reps, time, or ROM (`ScoringParams` with `.reps`, `.time`, or `.rom`), with an adjustable target. **Target reps progress** sets `showTargetProgress` and `EndExercisePreferences.TargetBased`, so the assessment ends each exercise at its target. When target progress is off and every exercise is rep-scored, the demo starts a regular timed workout instead (rep-timer mode).
- **Start Built-In Assessment** lets you choose a Fitness, Body 360, Cardio, Strength, or Custom assessment and starts it with `startAssessmet`. The demo also hides the `pushupKneesOnFloor` feedback from the UI with `setFeedbacksUIToExclude`.
- **Start Program** calls `startWorkoutFromProgram` with a sample `WorkoutConfig`; replace `YOUR_PROGRAM_ID` with your program.
- **Guidance Mode** lists the movements that support guidance (`GuidanceModePolicy.exerciseUsesDefaultGuidanceOrchestration(detector:)`), marks the ones with longer step sequences with a star, and starts the selected movement with `guidanceMode = true`. See [Guidance Mode](#guidance).
- **UI Settings** persists appearance (color theme, skeleton preset and fine-tuning, with a live preview), audio, calibration, pause types, language, assessment end and counter preferences, instruction-video mode, and session-behavior choices between launches.

## 7. Model and Asset Delivery <a name="asset-delivery"></a>

SMKitUI 2.7.3 downloads models and required SDK assets from the server during configuration and before a relevant session begins. The SDK does not include bundled fallback models. Keep the device online for the first configuration and asset download; a valid, previously downloaded cache can be used offline later.

`SMModelDownloadPolicy` controls how configuration uses the downloaded cache. Its fallback is a previously server-downloaded cache only, never an embedded model. See [Configure](#conf).

### Pre-download and offline testing

Configure online, build/select the custom workout, and use the **Download** control (or `SMKitUIModel.predownloadWorkoutAssets`) before starting it. Wait for successful completion. Required models must also have completed preparation. Then switch to airplane mode and start the same workout. Offline authorization is valid for 10 days; reconnect and configure again when it expires. A successful asset download alone does not establish model or authorization readiness.

Cancelled or failed downloads preserve completed cache files. Superseded vocals are reclaimed only after verified replacements are available; active and saved offline workout references remain protected.

## 8. Excluding Feedback <a name="feedback"></a>

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

## 9. Modifying Feedback Parameters <a name="modify"></a>

You have the ability to modify specific feedback parameters for exercises.
This allows you to customize the thresholds and ranges for feedback detection.

Build the modifications dictionary, keyed by detector name, and pass it when you start the session:

```swift
let modifications: [String: Any] = [
    "Crunches": [
        // Feedback/parameter name: [parameter values]
        "DepthCrunchesShallowDepth": ["low": 0.1, "high": 0.9],
        // Add more parameters as needed
    ]
]

try SMKitUIModel.startWorkout(
    viewController: self,
    workout: workout,
    delegate: self,
    modifications: modifications
)
```

`startAssessmet` and `startCustomAssessment` accept the same `modifications:` parameter.

## 10. Setting Text Language <a name="language"></a>

You can change the text language (default is English). Supported languages are `.English`, `.Hebrew`, and `.Mandarin`.
To do this, follow the example below:

```swift
let lang = SencySupportedLanguage.English

SMKitUIModel.setSessionLanguage(language: lang)
SMKitUIModel.setPhoneCalibrationLanguage(language: lang)
```

To download voice feedback in another language during configuration, pass `language:` to `configure`. See [Configure parameters](#conf).

## 11. Setting Pause Types <a name="pause"></a>
In SMKitUI you have the ability to choose what buttons will appear on the pause alert to do so you need to call setAllowedPauseTypes before the session starts like so:

```swift
let pauseTypes:[PauseAlertType] = [.StartOver, .Skip, .Quit]
try SMKitUIModel.setAllowedPauseTypes(types: pauseTypes)
```

`setAllowedPauseTypes` throws `SMWorkoutError.PauseAlertTypeCantByEmpty` when the list is empty.

### `PauseAlertType`
| Type                | Description                           |
|---------------------|---------------------------------------|
| Resume              | will resume the workout               |
| StartOver           | will start over the exercise          |
| Skip                | will skip the exercise                |
| Quit                | will quit the workout or assessment   |
| Rest                | will show the rest action             |
| Switch              | will show the switch action           |
| Guidance            | will restart the exercise in guidance mode (for exercises that support it) |

## 12. Audio and Feedback <a name="audio"></a>

Set these properties before starting a session unless noted otherwise.

### Coaching frequency
Controls how often optional spoken coaching plays: corrections, praise after a fix, and encouragement. Instructions, calibration, countdowns, rep announcements, and visuals are not affected. It can also be changed during a workout; the current clip finishes first.

```swift
SMKitUIModel.feedbackFrequency = .normal   // .off, .correctionsOnly, .low, .normal (default), .high
```

| Frequency | Corrections per feedback per exercise | Praise after a fix | Encouragement |
|-----------|---------------------------------------|--------------------|---------------|
| `.off` | None | None | None |
| `.correctionsOnly` | 1 | None | None |
| `.low` | 1 | Once per exercise | Every 6 good reps or 20 seconds of good holding |
| `.normal` | Default SDK behavior | Default | Default |
| `.high` | Up to 4 | Each fix | Frequent |

From Objective-C, use `SMFeedbackSettings.frequency`.

### Essential Guidance
Essential Guidance reduces optional speech while keeping exercise instructions: short intros, no spoken rep milestones, at most one praise clip per exercise, and at least 15 seconds between corrections. Rep sounds and visual guidance stay on.

```swift
SMKitUIModel.essentialGuidanceEnabled = true   // nil (default) = automatic, true = on, false = off

// When essentialGuidanceEnabled is nil, turn Essential Guidance on automatically
// if external audio (music or podcast) is playing when the session starts. Default false.
SMKitUIModel.automaticallyEnableEssentialGuidanceForExternalAudio = true

// The resolved state.
let active = SMKitUIModel.isEssentialGuidanceActive
```

### Audio mixing and external audio
```swift
SMKitUIModel.allowAudioMixing = true            // Default true. External apps (music, podcasts) keep playing; the built-in soundtrack is muted.
SMKitUIModel.showExternalAudioControl = true    // Default true. Shows the in-session audio source button. Requires allowAudioMixing.
SMKitUIModel.duckExternalAudioDuringVocals = true // Default true. Set false to play vocals over music at a steady level.
SMKitUIModel.usePlayAndRecordForSDKSounds = false // Default false. Use a recording-compatible .playAndRecord audio session for SDK sounds.
```

If your app plays its own voice audio during a workout, report it so the SDK lowers external audio around it. Balance each begin with an end:

```swift
SMKitUIModel.beginExternalAudioActivity(reason: "coach-message")
// ... your audio plays ...
SMKitUIModel.endExternalAudioActivity(reason: "coach-message")

// On teardown:
SMKitUIModel.clearExternalAudioActivities()
```

### Volume
```swift
SMKitUIModel.showWorkoutVolumeControls = true // Default false. Shows a compact in-workout volume sidebar.
SMKitUIModel.workoutVolume = 0.8              // SDK audio gain relative to device volume, 0...1. Default 1.
SMKitUIModel.musicVolume = 0.5                // Built-in soundtrack gain. nil (default) keeps the SDK levels.
```

These change only SDK audio, never another app's volume or the device volume.

### Hold and position sounds
```swift
SMKitUIModel.holdPositionSoundEnabled = true  // Default false. Plays a quiet loop during static and mobility holds.
```

Spoken corrections when the user leaves a static or mobility position are controlled per exercise with `SMExercise.positionExitVocalsEnabled` (default `true`).

### External music provider
Your app can show its own music service inside the workout (now-playing info and play/pause/next/previous/shuffle controls) by implementing `SMKitUIExternalMusicProvider`. The SDK never handles credentials or networking for the service.

```swift
final class MyMusicProvider: SMKitUIExternalMusicProvider {
    func start(session: SMKitUIExternalMusicSession, completion: @escaping (Result<Void, Error>) -> Void) {
        // Start playing session.identifier
        completion(.success(()))
    }
    func perform(_ command: SMKitUIExternalMusicCommand, completion: @escaping (Result<Void, Error>) -> Void) {
        // .play, .pause, .next, .previous, .setShuffle(Bool)
        completion(.success(()))
    }
    func setStateHandler(_ handler: ((SMKitUIExternalMusicState) -> Void)?) {
        // Keep the handler and call it with SMKitUIExternalMusicState when playback changes
    }
}

let provider = MyMusicProvider()                 // The SDK holds the provider weakly; keep a reference.
SMKitUIModel.externalMusicProvider = provider
SMKitUIModel.externalMusicSession = SMKitUIExternalMusicSession(identifier: "playlist-id", playlistName: "Morning Run")

// Call right before your provider opens its companion app, so the workout
// doesn't pause for that one switch to the background.
SMKitUIModel.protectWorkoutFromNextExternalMusicAppSwitch()
```

Both `externalMusicProvider` and `externalMusicSession` must be set for the music controls to appear.

### Dumbbell weight by voice
Dumbbell exercises show a weight scanner. To let users say the weight, provide a voice-input bridge; your app owns speech recognition:

```swift
final class WeightVoiceInput: SMKitUIDumbbellWeightVoiceInputProvider {
    func requestDumbbellWeightInput(for context: SMKitUIDumbbellWeightVoiceInputContext,
                                    completion: @escaping (SMDumbbellWeight?) -> Void) {
        // Listen in context.languageCode, then:
        completion(SMDumbbellWeight(value: 10, unit: .kg))
    }
    func cancelDumbbellWeightInput(for context: SMKitUIDumbbellWeightVoiceInputContext) {
    }
}

SMKitUIModel.dumbbellWeightVoiceInputProvider = weightVoiceInput // Held weakly.
```

### Button tutorial audio
```swift
SMKitUIModel.enableButtonTutorial = true
SMKitUIModel.buttonTutorialCompletionAudioURL = Bundle.main.url(forResource: "MyTutorialDone", withExtension: "mp3") // Optional override
```

## 13. Heart Rate and Apple Watch <a name="heart-rate"></a>

### Live heart rate from your app
The SDK can display live heart rate that your app supplies from any source (Apple Watch, Bluetooth strap, ...). The SDK does not request HealthKit access or connect to devices itself.

```swift
SMKitUIModel.enableLiveHeartRateDisplay = true   // Default false

// Each time your heart-rate source reports a sample (safe from background callbacks):
SMKitUIModel.updateLiveHeartRate(bpm: 128, timestamp: Date())

// When the source disconnects:
SMKitUIModel.clearLiveHeartRate()
```

Samples older than 15 seconds are rejected, and the display clears after 15 seconds without an update.

### Watch companion and heart-rate rest
```swift
SMKitUIModel.enableWatchCompanion = true   // Default false. Apple Watch connectivity for heart rate, rep counts, and workout state.
SMKitUIModel.enableHeartRateRest = true    // Default false. Suggests rest when heart rate is high. Requires enableWatchCompanion.
SMKitUIModel.heartRateRestThreshold = 140  // BPM. Default 160.
```

Enable these only when your app has an Apple Watch app. `WatchConnectivityManager.shared` exchanges messages with your watch app while `enableWatchCompanion` is on. Heart rate received from the watch is used for heart-rate rest automatically; watch remote controls are forwarded to your delegate:

```swift
final class WatchBridge: WatchConnectivityManagerDelegate {
    func watchDidRequestPause()  { try? SMKitUIModel.pauseSDK() }
    func watchDidRequestResume() { try? SMKitUIModel.resumeSDK() }
    func watchDidRequestSkip()   { _ = SMKitUIModel.skipCurrentExercise() }
    func watchDidRequestStartWorkout(workoutId: String?) { /* start the requested workout */ }
}

WatchConnectivityManager.shared.delegate = watchBridge // Held weakly.
WatchConnectivityManager.shared.activate()

// Send updates to the watch:
WatchConnectivityManager.shared.sendRepCount(12, exerciseName: "Squat Regular")
WatchConnectivityManager.shared.sendWorkoutState(.playing) // .playing, .paused, .bodyCal
WatchConnectivityManager.shared.sendBadFeedback()
```

`isPaired`, `isWatchAppInstalled`, and `isReachable` report the watch connection. The message keys are in `WatchMessageKey`:

| Key | Direction | Content |
|-----|-----------|---------|
| `heartRate` | Watch → phone (and phone → watch) | Heart rate in BPM. |
| `repCount`, `exerciseName` | Phone → watch | Current rep count and exercise. |
| `badFeedback` | Phone → watch | A form correction occurred (for example to trigger a haptic). |
| `workoutState` | Phone → watch (application context) | `WatchWorkoutState` raw value. |
| `pause`, `resume`, `skip` | Watch → phone | Remote controls for the running workout. |
| `startWorkout` | Watch → phone | A workout identifier requested from the watch. |

The demo exposes these switches but does not include a Watch app target.

## 14. Calibration and Visuals <a name="visuals"></a>

### Theme
```swift
SMKitUIModel.colorTheme = .green   // .blue, .green (default), .purple, .orange, .silver, .gold, .pink
```

### Phone and body calibration
```swift
try SMKitUIModel.startWorkout(viewController: self, workout: workout, delegate: self,
                              showPhoneCalibration: false) // Skip the phone-calibration screen

SMKitUIModel.playPhoneCalibrationAudio = true        // Default false. Spoken phone-calibration instructions.
SMKitUIModel.playBodyCalibrationAudio = true         // Default true. "Get in frame" and in-zone vocals.
SMKitUIModel.showRowingPhoneCalibration = true       // Default true. Set false to handle calibration yourself for Rowing workouts.
SMKitUIModel.sendInitialBodyCalibrationStatus = false // Default false. Report one body-calibration status from the first frame.
SMKitUIModel.enableBodyCalibrationScan = false       // Default false. Replace skeleton cues with a one-time blue body scan after calibration.
```

`showPhoneCalibration` can also be passed to built-in and custom assessment starts. The demo exposes this choice in **UI Settings**.

### Skeleton
Use a preset for quick theming:
```swift
SMKitUIModel.skeletonPreset = .neonGlow
```

Available presets: `default`, `minimalDots`, `thinOutline`, `monochromeClean`, `neonGlow`, `boldHighlight`, `softFill`, `wireframe`, `highContrast`, `pastel`, `darkOutline`, `minimalLine`, `doubleStroke`, `gradientReady`, `subtleShadow`, `classic`, `athletic`, `premium`, `hologram`, `matte`, `neonPulse`, `outlineOnly`, `slim`, `thick`, `studio`, `accessibility`.

Or fine-tune individual properties:
```swift
SMKitUIModel.skeletonHidden = false
SMKitUIModel.skeletonConnectionStyle = .solid    // none, dotted, dashed, solid, longDashed, thinDots, dotDashed, rounded
SMKitUIModel.skeletonJointShape = .circle        // circle, square, triangle, diamond, star, hexagon
SMKitUIModel.skeletonDotsOpacity = 1.0           // 0–1
SMKitUIModel.skeletonConnectionsOpacity = 0.8    // 0–1
SMKitUIModel.skeletonDotsGlow = 0.5              // 0–1
SMKitUIModel.skeletonConnectionsGlow = 0.3       // 0–1
SMKitUIModel.skeletonLineWidthScale = 1.0        // 0.5–2
SMKitUIModel.skeletonOutlineScale = 1.0          // 0.5–2
SMKitUIModel.skeletonSoftness = 0.0              // 0–1
SMKitUIModel.skeletonAnimationDuration = 0       // Seconds. 0 = instant; ~0.02 balanced; up to ~0.05 smoother
SMKitUIModel.skeletonDotsInnerColorOption = .white   // nil = preset default
SMKitUIModel.skeletonDotsOuterColorOption = .cyan
SMKitUIModel.skeletonConnectionsInnerColorOption = .white
SMKitUIModel.skeletonConnectionsOuterColorOption = .cyan
```

`SkeletonColorOption` values: `white`, `black`, `red`, `blue`, `green`, `yellow`, `orange`, `purple`, `gray`, `cyan`, `lightGray`, `darkGray`, `offWhite`, `charcoal`, `lightBlue`, `darkBlue`, `lightGreen`, `darkGreen`, `lightPurple`, `darkPurple`, `gold`, `darkGold`, `lightPink`, `darkPink`, `mediumGray`, `silver`, `navy`, `forestGreen`, `lavender`, `rosePink`.

More skeleton options:
```swift
SMKitUIModel.skeletonOnlyDuringBodyCalibration = true // Default false. Show the skeleton only as short fades at key moments (calibration, position changes, resume).
SMKitUIModel.showAllSkeletonKeypoints = true          // Default false. Render all 28 body joints.
```

`skeletonHidden` takes priority over every other skeleton setting.

### Other visuals
```swift
SMKitUIModel.enableSmallBodyPartFocus = true          // Default false. Instruction-video close-ups for supported exercises (prefer the per-exercise flag).
SMKitUIModel.mobilityFlowHoldIndicatorStyle = .liquidGlass // .classic (default) or .liquidGlass
SMKitUIModel.enableExerciseSummaryTimingMetrics = true // Default false. Adds rep-time and longest-hold metrics to ExerciseData.
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

## 15. Guidance Mode <a name="guidance"></a>

Guidance mode teaches an exercise step by step before the regular set: the instruction video pauses on each step, a vocal explains it, and the user moves on once the SDK detects the step. Guidance is off unless you set `guidanceMode = true` on the exercise.

Check whether a movement supports guidance:

```swift
let supported = GuidanceModePolicy.exerciseUsesDefaultGuidanceOrchestration(detector: "SquatRegular")
```

### Dynamic exercises
For rep-based exercises, guidance runs setup → one complete movement → acknowledgement. The user gets through the movement step by performing an accepted rep, and then the timed set begins.

```swift
let squat = SMExercise(
    name: "Squat Regular",
    exerciseIntro: nil,
    totalSeconds: 30,
    videoInstruction: "SquatRegular",
    uiElements: nil,
    detector: "SquatRegular",
    exerciseClosure: nil,
    guidanceMode: true
)
```

### Mobility exercises
For mobility and static exercises, guidance walks through each position step (for example orient → setup → action → hold) and finishes in the hold.

```swift
let sideBend = SMExercise(
    name: "Standing Side Bend Right",
    exerciseIntro: nil,
    totalSeconds: 25,
    videoInstruction: "StandingSideBendRight",
    uiElements: nil,
    detector: "StandingSideBendRight",
    exerciseClosure: nil,
    guidanceMode: true
)

// Optional: choose which part of the instruction video plays for each step.
sideBend.guidanceVideoSegments = [
    "phase1_orient": .freeze(at: 0),
    "phase2_setup": .play(from: 0, to: 3),
    "phase4_action": .play(from: 3, to: 8),
    "phase5_hold": .freeze(at: 8)
]
```

Segment keys: `phase1_orient`, `phase2_setup`, `phase3_prepare`, `phase4_action`, `phase5_hold`. Each value is `.freeze(at:)` (show one frame) or `.play(from:to:)` (play a range, in seconds). Without segments, the video plays as usual.

[Mobility Flow](#mobility-flow) exercises always run with guidance.

### Guidance suggestions
When a user struggles with a supported static, mobility, or body-assessment exercise, the SDK can suggest switching to guidance mode:

```swift
SMKitUIModel.enableGuidanceModeSuggestion = true // Default false. Applies to all supported exercises.
exercise.enableGuidanceModeSuggestion = false     // Per exercise, default true. Opt a single exercise out.
```

Add `.Guidance` to `setAllowedPauseTypes` to let users restart an exercise in guidance mode from the pause menu.

## 16. Advanced Configuration <a name="advanced"></a>

These properties must be set **before** starting a session.

### Intelligence / Fatigue Detection
```swift
SMKitUIModel.enableIntelligenceRest = true  // Default false. In-session rest suggestions based on fatigue (slower pace, form slippage).
```

### Accurate Pose Estimation
```swift
SMKitUIModel.accuratePoseEstimation = true  // Default true. Set false for lower CPU use with lower keypoint accuracy.
```

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
SMKitUIModel.startTimerOnFirstActivity = true           // Default true. The timer starts at the first rep or first in-position.
SMKitUIModel.enablePhoneMovementCountPrevention = true  // Default true. Phone movement blocks rep counting and in-position updates.
SMKitUIModel.enableVariationMismatchFeedback = true     // Default false. One-time vocal when the user performs a different variation.
SMKitUIModel.enableButtonTutorial = true                // Default false. One-time tutorial for hover-activated buttons, after body calibration.
SMKitUIModel.workoutContinuationTimerDuration = 8       // Seconds. Default 10. The continuation starts automatically when the timer ends.
```

## 17. Exercise and Workout Options <a name="exercise-options"></a>

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

`UIElement` values: `repsCounter`, `timer`, `gaugeOfMotion`, `countdownTimer`, `quickMotion`, and `holdingPosition` (hold progress for static and mobility exercises).

### Camera, phone position, and intro
```swift
let exercise = SMExercise(
    name: "Glutes Bridge",
    exerciseIntro: nil,
    totalSeconds: 30,
    videoInstruction: "GlutesBridge",
    detector: "GlutesBridge",
    exerciseClosure: nil,
    phonePosition: .Floor,      // .Floor or .Elevated. nil = the detector's default
    useWideAngleCamera: true    // nil = the detector's default camera
)
exercise.shortIntro = true      // Use the short spoken intro
```

`customInstruction:` (a `URL`) can be passed to the initializer to provide a custom instruction asset.

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
    playPreExerciseCountdown: true,   // Countdown audio during the last 5 seconds
    playRepMilestoneVoice: true,      // Spoken rep count at milestones
    repMilestoneInterval: 5,          // 1, 5, or 10. 0 = automatic
    playSoundOnEachRep: true          // Short sound after each rep
)
highKnees.paceLimitEnabled = false           // nil = detector default. false disables minimum-pace coaching.
highKnees.intentVoiceFeedbackEnabled = true  // Default false. Next-step voice feedback after a sustained intent.
```

For static, mobility, and body-assessment exercises, `positionExitVocalsEnabled` (default `true`) controls the spoken correction when the user leaves the position.

### Target reps
End a dynamic exercise when a rep target is reached:

```swift
let pushups = SMExercise(
    name: "Pushups",
    exerciseIntro: nil,
    totalSeconds: 60,
    videoInstruction: "PushupRegular",
    detector: "PushupRegular",
    exerciseClosure: nil,
    playTargetRepsCompletionVoice: true  // Default false. A completion vocal when the target is reached.
)
pushups.targetReps = 12                         // nil or ≤ 0 keeps a regular timed exercise
pushups.targetRepsTimerDisplayMode = .repsProgress // .repsProgress (default) or .timeProgress for the bottom timer
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
squat.adaptiveRomFeedbackEnabled = true   // Default false. Personal success zone for exercises with a ROM gauge.
squat.adaptiveRomWarmupReps = 2           // Default 3. Reps used to calibrate the first time.
```

### Instruction close-ups and rep replay
```swift
exercise.enableSmallBodyPartFocus = true   // Default false. Instruction-video close-up, for supported exercises.

// Optional: the part of the instruction video that shows one repetition, in seconds.
exercise.instructionRepTiming = SMInstructionRepTiming(videoName: "SquatRegular", startSeconds: 1.2, endSeconds: 3.4)
```

### Stretch Sets
Repeat the same hold several times with rest between holds (static, mobility, and body-assessment exercises):

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

### Position reps
Count discrete holds of a static, mobility, or body-assessment position. Each rep is a continuous hold of `secondsPerRep`, followed by leaving the position:

```swift
let plank = SMExercise(
    name: "Plank Holds",
    exerciseIntro: nil,
    totalSeconds: 60,
    videoInstruction: "PlankHighStatic",
    detector: "PlankHighStatic",
    exerciseClosure: nil
)
plank.positionRepConfig = SMPositionRepConfig(targetReps: 5, secondsPerRep: 5)
```

### Mobility reps
Count repetitions of reaching a mobility target and returning to neutral:

```swift
if SMMobilityRepConfig.supports(detector: "HamstringMobility") {
    exercise.mobilityRepConfig = SMMobilityRepConfig(targetReps: 8)
}
```

### Mobility Flow <a name="mobility-flow"></a>
A Mobility Flow runs several mobility holds as one continuous exercise, with guidance for each block:

```swift
let flowConfig = SMMobilityFlowConfig(
    blocks: [
        SMMobilityFlowBlock(detector: "SeatedBowArrowThoracicMobilityLeft", repetitions: 2, secondsPerRep: 10),
        SMMobilityFlowBlock(detector: "RhomboidStretch", repetitions: 2, secondsPerRep: 10),
        SMMobilityFlowBlock(detector: "SeatedBowArrowThoracicMobilityRight", repetitions: 2, secondsPerRep: 10)
    ],
    fiveSecondsLeftCueEnabled: true   // "Five seconds left" cue for holds of 15 seconds or more
)

let flow = SMExercise(name: "Upper Body Mobility Flow", mobilityFlowConfig: flowConfig)
```

- `SMMobilityFlowSupport.supportedExercises` lists the detectors that can be used as blocks.
- `SMMobilityFlowSupport.canConnect(from:to:)` and `connectableExercises(from:)` tell you which blocks can follow each other.
- A block can use a mobility rep instead of a timed hold, `SMMobilityFlowBlock(detector:mobilityRepConfig:useWideAngleCamera:)`, for detectors where `SMMobilityFlowSupport.supportsRangeOfMotion(for:)` is true.
- `useWideAngleCamera` can be set per block.
- Results arrive in `ExerciseData.mobilityFlowSummary`.

### Combinations
Two movements performed back to back as one counted rep. See [Exercise Combinations](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/Combinations.md).

### Dumbbell weight
Supply the weight for a dumbbell exercise to skip the weight scanner. It is saved in `ExerciseData.dumbbellWeight`; the user can still rescan before starting.

```swift
exercise.dumbbellWeight = SMDumbbellWeight(value: 12.5, unit: .kg) // .kg or .lb
```

### Section titles and groups
Show a section title and circuit/superset progress for an exercise:

```swift
exercise.displayContext = SMExerciseDisplayContext(
    sectionTitle: "Warm-Up",          // Standard titles (Warm-Up, Workout, Main Set, Strength, Cardio, Core, Mobility, ...) have built-in voices
    group: SMExerciseDisplayGroup(id: "circuit-1", kind: .circuit, number: 1, title: "Circuit 1"), // .circuit, .superset, .block, .custom
    sectionTitleSoundKey: nil,        // Optional custom title audio (asset key, URL, or file path)
    playsTitleSound: true             // Set false to show the title silently
)
```

### Guidance Video Segments
See [Guidance Mode](#guidance).

### Workout sounds
`SMWorkout` accepts optional audio overrides. Each value is an asset key, a URL, or a file path:

```swift
let workout = SMWorkout(
    id: "my-workout",
    name: "My Workout",
    workoutIntro: introPath,      // Played after body calibration
    soundtrack: soundtrackPath,   // Background music
    exercises: exercises,
    setPhone: nil,                // Phone-calibration prompt
    getInFrame: nil,              // "Get in frame" body-calibration prompt
    bodycalFinished: nil,         // Body calibration completed
    workoutClosure: closurePath   // Played at the end
)
```

### Workout Continuation <a name="workout-continuation"></a>
An optional segment after the main exercises. The user is asked whether to continue; when nobody answers within `SMKitUIModel.workoutContinuationTimerDuration`, it starts automatically.

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

### Loading workouts from JSON
`SMWorkout` and `SMExercise` are `Codable`. Exercises are listed under `activities`:

```swift
let json = """
{
  "id": "json-workout",
  "name": "JSON Workout",
  "activities": [
    { "prettyName": "Squat Regular", "detector": "SquatRegular", "totalSeconds": 30,
      "uiElements": ["timer", "repsCounter"], "targetReps": 15 }
  ]
}
"""
let workout = try JSONDecoder().decode(SMWorkout.self, from: Data(json.utf8))
```

`SMWorkout(FromJson:)` and `SMExercise(FromJson:)` accept an already-parsed `[String: Any]` dictionary.

## 19. MCP Server Access <a name="mcp"></a>

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

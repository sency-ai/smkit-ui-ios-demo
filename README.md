# SMKitUI iOS Demo

1. [ Installation. ](#inst)
2. [ Setup. ](#setup)
3. [ Configure. ](#conf)
4. [ Start. ](#start)

<a name="inst"></a>
## 1. Installation

### Cocoapods
```
// [1] add the source to the top of your Podfile.
source 'https://bitbucket.org/sency-ios/sency_ios_sdk.git'
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

### SPM

Comming soon


<a name="setup"></a>
## 2. Setup
Add camera permission request to `Info.plist`
```Xml
<key>NSCameraUsageDescription</key>
<string>Camera access is needed</string>
```


<a name="conf"></a>
## 3. Configure
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


<a name="start"></a>
## 4. Start
Implement **SMKitUIWorkoutDelegate**.
```Swift
extension ViewController:SMKitUIWorkoutDelegate{
    // Runtime error callback
    func handleWorkoutErrors(error: Error) {
        
    }

    // Workout session end callback
    func workoutDidFinish(summary: WorkoutSummaryData) {
        // Will close SMKitUI.
        SMKitUIModel.exitSDK()
    }

    // Exit workout callback
    func didExitWorkout(summary: SMKitUIDev.WorkoutSummaryData) {
        //Will close SMKitUI.
        SMKitUIModel.exitSDK()
    }
}
```
    
### Start Assessment
**startAssessment** starts one of Sency's blueprint assessments.
```Swift
func startAssessmentWasPressed(){
    do{
        // Start assessment
        try SMKitUIModel.startAssessmet(viewController: self, type: AssessmentTypes.Fitness, delegate: self)
    }catch{
        showAlert(title: error.localizedDescription)
    }
}
```

### Start Custom Workout
**startWorkout** starts a custom workout.
```Swift
// List of exercises
let exercises:[SMExercise] = [
    SMExercise(
        name: "", // display name of the exercise
        exerciseIntro: "", // (optinal) a path to intro audio file
        totalSeconds: 30, // exercise time (seconds)
        introSeconds: 10, // (optinal) total display time (seconds) of the instruction video before the exercise starts
        videoInstruction: "", // (optinal) a path to instruction video file
        uiElements: [.gaugeOfMotion, .timer, .repsCounter], // the UI elements to show
        detector: "", // SMExerciseType
        repBased: true, // is the exerise repetition based
        exerciseClosure: "" // (optinal) a path to outro audio file
    )
]

let workout = SMWorkout(
    id: "", // workout id
    name: "", // workout name
    workoutIntro: "", // (optinal) a path to intro audio file
    soundtrack: "", // (optinal) a path to a soundtrack audio file
    exercises: exercises, // sequence of exercises
    workoutClosure: "", // (optinal) a path to outro audio file
)

do{
    try SMKitUIModel.startWorkout(viewController: self,workout: workout, delegate: self)
}catch{
    print(error)
}
```

Having issues? [Contact us](support@sency.ai) and let us know what the problem is.

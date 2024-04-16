# [smkit-ui-ios-demo](https://github.com/sency-ai/smkit-sdk)

## Table of contents
1. [ Installation ](#inst)
2. [ Setup ](#setup)
3. [ Configure ](#conf)
4. [ Start ](#start)


## 1. Installation <a name="inst"></a>

### Cocoapods
```ruby
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

```Comming soon```


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
    func didExitWorkout(summary: WorkoutSummaryData) {
        //Will close SMKitUI.
        SMKitUIModel.exitSDK()
    }
    
    //When the user finish a exercise this  function will be called with the exercise data.
    func exerciseDidFinish(data: ExerciseData) {
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

### Start Program
**startWorkoutFromProgram** starts a workout program according to yor **WorkoutConig**.

first let's create a `WorkoutConfig`:

```Swift
let workoutConfig = WorkoutConfig(
    week: 1, // The program week
    bodyZone: .FullBody, // The program bodyZone
    difficultyLevel: .HighDifficulty, // The program difficulty
    workoutDuration: .Short, // The program duration
    programID: "YOUR_PROGRAM_ID"
)
```

Now we can start the program:

```Swift
SMKitUIModel.startWorkoutFromProgram(viewController: self, workoutConfig: workoutConfig, delegate: self) { error in
    print(error)
}
```

Having issues? [Contact us](mailto:support@sency.ai) and let us know what the problem is.

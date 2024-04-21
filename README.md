# [smkit-ui-ios-demo](https://github.com/sency-ai/smkit-sdk)

## Table of contents
1. [ Installation ](#inst)
2. [ Setup ](#setup)
3. [ Configure ](#conf)
4. [ Start ](#start)
5. [ Data ](#data)


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
    
### [Start Assessment](https://github.com/sency-ai/smkit-sdk/blob/main/AI-Fitness-Assessment.md)
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
> Check out [this info page](https://github.com/sency-ai/smkit-sdk/blob/main/AI-Fitness-Assessment.md) if you want to learn more about **Sency's AI Fitness Assessment**

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
----------

## Available Data Types <a name="data"></a>
#### `ExerciseData`
| Type              | Format                                                         | Description                                                                                                  |
|-------------------|----------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| sessionId         | `String`                                                       | The identifier for the session in which the exercise was performed.                                          |
| prettyName        | `String`                                                       | The user-friendly name of the exercise activity.                                                             |
| name              | `String`                                                       | The technical name identifier for the exercise activity.                                                     |
| targetTime        | `Double?`                                                      | The targeted duration for the exercise session in seconds (optional).                                        |
| startTime         | `String`                                                       | The start time of the exercise session in "YYYY-MM-dd HH:mm:ss.SSSZ" format.                                 |
| endTime           | `String`                                                       | The end time of the exercise session in "YYYY-MM-dd HH:mm:ss.SSSZ" format.                                   |
| totalTime         | `Double`                                                       | The total time taken for the exercise session in seconds.                                                    |
| performanceScore  | `Float`                                                        | The score representing the user's performance in the exercise.                                               |
| techniqueScore    | `Float`                                                        | The score representing the user's technique during the exercise.                                             |
| totalScore        | `Float`                                                        | The final calculated score for the exercise session, considering both performance and technique.             |

#### `WorkoutSummaryData`
| Type              | Format                                 | Description                                                                                                  |
|-------------------|----------------------------------------|--------------------------------------------------------------------------------------------------------------|
| sessionId         | `String`                               | A unique identifier for the workout session, generated as a UUID string.                                     |
| exercises         | `[ExerciseData]`                       | An array of `ExerciseData` objects representing each exercise performed in the session.                      |
| score             | `Int`                                  | The overall score for the workout session based on the exercises' scores.                                    |
| completionRatio   | `Float`                                | A float value representing the ratio of exercises completed successfully over the total number of exercises. |
| startTime         | `String`                               | The start time of the workout session in "YYYY-MM-dd HH:mm:ss.SSSZ" format.                                  |
| endTime           | `String`                               | The end time of the workout session in "YYYY-MM-dd HH:mm:ss.SSSZ" format.                                    |
| totalTime         | `Double`                               | The total time taken for the workout session in seconds.                                                     |
| startDate         | `Date`                                 | The start date and time of the workout session.                                                             |
| finishedExercises | `Float`                                | The count of exercises that have been completed in the session.                                             |

## Additional functionalities
### Start Program
**startWorkoutFromProgram** starts a workout program according to yor **WorkoutConfig**.

Create a `WorkoutConfig`:
```Swift
let workoutConfig = WorkoutConfig(
    week: 1, // The program week
    bodyZone: .FullBody, // The program bodyZone
    difficultyLevel: .HighDifficulty, // The program difficulty
    workoutDuration: .Short, // The program duration
    programID: "YOUR_PROGRAM_ID"
)
```

Start the program:
```Swift
SMKitUIModel.startWorkoutFromProgram(viewController: self, workoutConfig: workoutConfig, delegate: self) { error in
    print(error)
}
```
--------

Having issues? [Contact us](mailto:support@sency.ai) and let us know what the problem is.

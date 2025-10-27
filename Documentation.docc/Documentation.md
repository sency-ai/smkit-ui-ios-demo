# [smkit-ui-ios-demo](https://github.com/sency-ai/smkit-sdk)

## Table of contents
1. [ Installation ](#inst)
2. [ Setup ](#setup)
3. [ Configure ](#conf)
4. [ Start ](#start)
5. [ Data ](#data)


## 1. Installation <a name="inst"></a>

*Latest pod version: SMKitUI '1.3.8'*

### Cocoapods
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
Implement **SMKitUIWorkoutDelegate**.
```Swift
extension ViewController:SMKitUIWorkoutDelegate {
    // Runtime error callback
    func handleWorkoutErrors(error: Error) {
        
    }

    // Workout session end callback
    func workoutDidFinish() {
        // Will close SMKitUI.
        SMKitUIModel.exitSDK()
    }

    // Exit workout callback
    func didExitWorkout() {
        //Will close SMKitUI.
        SMKitUIModel.exitSDK()
    }
    
    // When the user finish a exercise this  function will be called with the exercise data.
    func exerciseDidFinish(data: ExerciseData) {
    }

    // When the summary payload is avilable this function will be called.
    func didReceiveSummaryData(data: WorkoutSummaryData?) {
    }
}
```
    
### [Start Assessment](https://github.com/sency-ai/smkit-sdk/blob/main/AI-Fitness-Assessment.md)
**startAssessment** starts one of Sency's blueprint assessments.
```Swift
func startAssessmentWasPressed(){
    do{
        let userData = UserData(gender: .Female, birthday: Date()) // This is optinal if not provided the SDK will requst from the user his age and gender
        
        // Start a Assessment workout with AssessmentTypes
        try SMKitUIModel.startAssessmet(viewController: self, type: AssessmentTypes.Fitness, userData: userData, delegate: self, onFailure: { error in
            // Handle failure error
    
            })
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
        exerciseIntro: nil, // (optinal) a path to intro audio file
        totalSeconds: 30, // exercise time (seconds)
        videoInstruction: nil, // (optinal) a path to instruction video file
        uiElements: [.gaugeOfMotion, .timer, .repsCounter], // the UI elements to show
        detector: "", // SMExerciseType
        exerciseClosure: nil // (optinal) a path to outro audio file
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

### Start Custom Assessment
**startAssessment** starts Sency's assessments with custom exercises.
```Swift
//[1] create a list of exercise with ScoringParams

let dynamicScoringParams = ScoringParams(type: .reps, scoreFactor: 0.8, targetTime: nil, targetReps: 10, targetRom: nil)
let staticScoringParams = ScoringParams(type: .time, scoreFactor: 0.8, targetTime: 10, targetReps: 0, targetRom: nil)

let intro = Bundle.main.path(forResource: "customWorkoutIntro", ofType: "mp3")
let soundtrack = Bundle.main.path(forResource: "full-body-long", ofType: "mp3")
let exercises:[SMExercise] = [
    .init(
        name: "High Knees",
        exerciseIntro: nil, // Custom sound,
        totalSeconds: 30,
        introSeconds: 5,
        videoInstruction: Bundle.main.path(forResource: "HighKnees", ofType: "mp4"),
        uiElements: [.repsCounter, .timer],
        detector: "HighKnees",
        exerciseClosure: nil, // Custom sound
        scoringParams: dynamicScoringParams
    ),
    .init(
        name: "Squat Regular Static",
        exerciseIntro: nil, // Custom sound,
        totalSeconds: 30,
        introSeconds: 5,
        videoInstruction: Bundle.main.path(forResource: "SquatRegularStatic", ofType: "mp4"),
        uiElements: [.gaugeOfMotion, .timer],
        detector: "SquatRegularStatic",
        exerciseClosure: nil, // Custom sound
        scoringParams: staticScoringParams
    ),
    .init(
        name: "Plank High Static",
        exerciseIntro: nil, // Custom sound,
        totalSeconds: 30,
        introSeconds: 5,
        videoInstruction: Bundle.main.path(forResource: "PlankHighStatic", ofType: "mp4"),
        uiElements: [.repsCounter, .timer],
        detector: "PlankHighStatic",
        exerciseClosure: nil, // Custom sound
        scoringParams: staticScoringParams
    )
]

// [2] Create assessment with the list of exerxises
let assessment = SMWorkout(
    id: "",
    name: "TEST",
    workoutIntro: intro,
    soundtrack: soundtrack,
    exercises: exercises,
    workoutClosure:nil // Custom sound
)

do{
// [3] call startCustomAssessment function with the customized assessmet from step 2
    try SMKitUIModel.startCustomAssessment(viewController: self, assessment: assessment, delegate: self) { error in
        self.showAlert(title: error.localizedDescription)
    }
}catch{
    showAlert(title: error.localizedDescription)
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

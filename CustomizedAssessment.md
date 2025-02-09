# Customized Assessmet

> The customized assessment enables you to create a personalized evaluation using the exercises and movements from our [Movement catalog](https://github.com/sency-ai/smkit-sdk/blob/main/SDK-Movement-Catalog.md), tailored to your professional standards or personal preferences.
> To understand the behavior of instruction videos, please refer to [Instruction Video Behavior](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/InstructionVideoBehavior.md)
> To see all Assessmet workout options, please refer to [Assessment Workout Options](https://github.com/sency-ai/smkit-ui-ios-demo/blob/main/Assessment-Workout-Options.md)


Implement **SMKitUIWorkoutDelegate**.
```Swift
extension ViewController:SMKitUIWorkoutDelegate{
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
    
    //When the user finish a exercise this  function will be called with the exercise data.
    func exerciseDidFinish(data: ExerciseData) {
    }
    
    //When the summary is avilable this function will be called.
    func didReceiveSummaryData(data: WorkoutSummaryData?) {
    }
}
```

### Start Customized Assessment
**startAssessment** starts Sency's assessments with custom exercises.
```Swift
//[1] create a list of exercise with ScoringParams

let dynamicScoringParams = ScoringParams(type: .reps, scoreFactor: 0.8, targetTime: nil, targetReps: 10, targetRom: nil)
let staticScoringParams = ScoringParams(type: .time, scoreFactor: 0.8, targetTime: 10, targetReps: 0, targetRom: nil)

let intro = Bundle.main.path(forResource: "customWorkoutIntro", ofType: "mp3")
let soundtrack = Bundle.main.path(forResource: "full-body-long", ofType: "mp3")
let exercises:[SMAssessmentExercise] = [
    .init(
        name: "High Knees",
        exerciseIntro: nil, // Custom sound,
        totalSeconds: 30,
        videoInstruction: Bundle.main.path(forResource: "HighKnees", ofType: "mp4"),
        uiElements: [.repsCounter, .timer],
        detector: "HighKnees",
        exerciseClosure: nil, // Custom sound
        closureFailedSound: nil, // Only applicable for EndExercisePreferences TargetBased will be played if user did not reach target
        summaryTitle: "High Knees",
        summarySubTitle: "This a subtitle",
        summaryTitleMainMetric: "Reps",
        summarySubTitleMainMetric: "clean reps",
        scoringParams: dynamicScoringParams
    ),
    .init(
        name: "Squat Regular Static",
        exerciseIntro: nil, // Custom sound,
        totalSeconds: 30,
        videoInstruction: Bundle.main.path(forResource: "SquatRegularStatic", ofType: "mp4"),
        uiElements: [.gaugeOfMotion, .timer],
        detector: "SquatRegularStatic",
        exerciseClosure: nil, // Custom sound
        closureFailedSound: nil, // Only applicable for EndExercisePreferences TargetBased will be played if user did not reach target
        summaryTitle: "Squat Regular Static",
        summarySubTitle: "This a subtitle",
        summaryTitleMainMetric: "Time",
        scoringParams: staticScoringParams
    ),
    .init(
        name: "Plank High Static",
        exerciseIntro: nil, // Custom sound,
        totalSeconds: 30,
        videoInstruction: Bundle.main.path(forResource: "PlankHighStatic", ofType: "mp4"),
        uiElements: [.repsCounter, .timer],
        detector: "PlankHighStatic",
        exerciseClosure: nil, // Custom sound
        closureFailedSound: nil, // Only applicable for EndExercisePreferences TargetBased will be played if user did not reach target
        summaryTitle: "Plank High Static",
        summarySubTitle: "This a subtitle",
        summaryTitleMainMetric: "Time",
        scoringParams: staticScoringParams
    )
]

// [2] Create assessment with the list of exerxises
let assessment = SMWorkoutAssessmet(
    id: "",
    name: "TEST",
    workoutIntro: intro,
    soundtrack: soundtrack,
    assessmentsExercises: exercises,
    workoutClosure:nil // Custom sound
)

do{
// [3] call startCustomAssessment function with the cystom assessmet from step 2
    try SMKitUIModel.startCustomAssessment(viewController: self, assessment: assessment, delegate: self) { error in
        self.showAlert(title: error.localizedDescription)
    }
}catch{
    showAlert(title: error.localizedDescription)
}
```

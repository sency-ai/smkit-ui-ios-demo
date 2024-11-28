# Workout

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

### Start Custom Workout
**startWorkout** starts a custom workout.
```Swift
// Create a sample list of exercises
let exercises:[SMExercise] = [
    SMExercise(
        name: "", // display name of the exercise
        exerciseIntro: "", // (optinal) a path to intro audio file
        totalSeconds: 30, // exercise time (seconds)
        videoInstruction: "", // (optinal) a path to instruction video file
        uiElements: [.gaugeOfMotion, .timer, .repsCounter], // the UI elements to show
        detector: "", // SMExerciseType
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


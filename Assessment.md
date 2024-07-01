# Assessment

Implement **SMKitUIWorkoutDelegate**.
```Swift
extension ViewController:SMKitUIWorkoutDelegate{
    // Runtime error callback
    func handleWorkoutErrors(error: Error) {
        
    }

    // Workout session end callback
    func workoutDidFinish(data: WorkoutSummaryData) {
        // Will close SMKitUI.
        SMKitUIModel.exitSDK()
    }

    // Exit workout callback
    func didExitWorkout(data: WorkoutSummaryData) {
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
You can choose the type of assessment by changing  `AssessmentTypes.Fitness` to `AssessmentTypes.Custom`
```Swift
func startAssessmentWasPressed(){
    do{
        let userData = UserData(gender: .Female, birthday: Date()) // This is optinal if not provided the SDK will requst from the user his age and gender.
        // Start assessment
        try SMKitUIModel.startAssessmet(viewController: self, type: AssessmentTypes.Fitness, userData: userData, delegate: self, onFailure: { error in

        })
    }catch{
        showAlert(title: error.localizedDescription)
    }
}
```
> Check out [this info page](https://github.com/sency-ai/smkit-sdk/blob/main/AI-Fitness-Assessment.md) if you want to learn more about **Sency's AI Fitness Assessment**
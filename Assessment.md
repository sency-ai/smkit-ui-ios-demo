# Assessment
>Sency offers two primary types of assessments: Sency Blueprint assessments and Customized assessments.

>**Sency Blueprint Assessments:** Developed in collaboration with Sency’s medical and fitness experts, these assessments provide a standardized, professional way to measure core aspects of movement, fitness, and a healthy lifestyle. Simply follow the "start assessment" instructions and select the [type of assessment](#assessment-types) you need.

>**Sency Customized Assessments:** For those who prefer to beuild their own assessments, you can create a customized evaluation using the exercises and movements from our movement catalog, according to your specific requirements (check the CustomizedAssessment.md file for more info).



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
    
    // When the user finish a exercise this  function will be called with the exercise data.
    func exerciseDidFinish(data: ExerciseData) {
    }
}
```
    
### Start Assessment
**startAssessment** starts one of Sency's blueprint assessments.
You can select the assessment `type` by setting the type to any value from the `AssessmentTypes` enum.
```Swift
// Fitness Assessmet exemple
func startFitnessAssessment(){
    do{
        let userData = UserData(gender: .Female, birthday: Date()) // This is optional if not provided the SDK will requst from the user his age and gender.
        // Start assessment
        try SMKitUIModel.startAssessmet(
        viewController: self,
        type: AssessmentTypes.Fitness,
        userData: userData,
        forceShowUserDataScreen:false, // if true it will allways show UserData screen.
        showSummary:true, // if true at the end of the workout the summary screen will be presented
        delegate: self,
        onFailure: { error in

        })
    }catch{
        showAlert(title: error.localizedDescription)
    }
}

// Custom Assessmet exemple
func startCustomAssessment(){
    do{
        let userData = UserData(gender: .Female, birthday: Date()) // This is optional if not provided the SDK will requst from the user his age and gender.
        // Start assessment
        try SMKitUIModel.startAssessmet(
        viewController: self,
        type: AssessmentTypes.Custom,
        customAssessmentID: "YOUR_CUSTOM_ASSESSMENT" // This is optional if you have multiple 'Custom Assessment' you can provide the assessment ID in order to start the assessment
        userData: userData,
        delegate: self,
        onFailure: { error in

        })
    }catch{
        showAlert(title: error.localizedDescription)
    }
}
```

### Blueprint AssessmentTypes <a name="assessment-types"></a>
| Name (enum)         | Description |More info|
|---------------------|---------------------|---------------------|
| Fitness             | For individuals of any activity level who seek to enhance their physical abilities, strength, and endurance through a tailored plan.| [Link](https://github.com/sency-ai/smkit-sdk/blob/main/Assessments/AI-Fitness-Assessment.md) |
| Body360                 | Designed for individuals of any age and activity level, this assessment determines the need for a preventative plan or medical support.| [Link](https://github.com/sency-ai/smkit-sdk/blob/main/Assessments/360-Body-Assessment.md) |
| Strength            |For individuals of any activity level who seek to assess their strength capabilities (core and endurance) * This assessment will be available soon. Contact us for more info.| [Link](https://github.com/sency-ai/smkit-sdk/blob/main/Assessments/Strength.md) |
| Custom              |If Sency created a tailored assessment for you, you probably know it, and you should use this enum.|  |

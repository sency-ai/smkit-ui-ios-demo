//
//  ViewController.swift
//  SMKitUIDemoApp
//
//  Created by netanel-yerushalmi on 18/03/2024.
//

import SwiftUI
import SMKitUI
import SMKit
import SMBase

class ViewController: UIViewController {

    lazy var mainView:UIView = {
        guard let view = UIHostingController(rootView: MainView(
            buildWorkoutWasPressed: buildWorkoutWasPressed,
            startAssessmentWasPressed: startAssessmentWasPressed,
            startCustomAssessmet: startCustomAssessmet,
            uiSettingsWasPressed: uiSettingsWasPressed
        )).view else {return UIView()}
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AuthManager.shared.delegate = self
        DemoSettingsStore.shared.applyToSDK()

        self.view.addSubview(mainView)
        NSLayoutConstraint.activate([
            mainView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            mainView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            mainView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            mainView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
        ])
    }

    private func makeExercise(from config: BuiltWorkoutExercise) -> SMExercise {
        let exercise = SMExercise(
            name: config.detector,
            exerciseIntro: nil,
            totalSeconds: config.duration,
            videoInstruction: config.detector,
            uiElements: nil,
            detector: config.detector,
            exerciseClosure: nil,
            quickMotionParams: nil,
            playPreExerciseCountdown: config.playPreExerciseCountdown,
            playRepMilestoneVoice: config.playRepMilestoneVoice,
            repMilestoneInterval: config.repMilestoneInterval,
            playSoundOnEachRep: config.playSoundOnEachRep,
            stretchSetConfig: config.stretchSetConfig
        )
        exercise.phonePosition = config.phonePositionChoice.phonePosition
        exercise.guidanceMode = config.guidanceChoice.boolValue
        exercise.useWideAngleCamera = config.wideAngleChoice.boolValue
        exercise.adaptiveRomFeedbackEnabled = config.adaptiveRomFeedbackEnabled
        exercise.adaptiveRomWarmupReps = max(1, config.adaptiveRomWarmupReps)
        exercise.shortIntro = config.shortIntro
        return exercise
    }

    private func startWorkout(
        from viewController: UIViewController,
        named name: String,
        exercises: [SMExercise],
        continuationExercises: [SMExercise]? = nil
    ) {
        DemoSettingsStore.shared.applyToSDK()
        let continuation = continuationExercises.flatMap { exercises -> SMWorkoutContinuation? in
            guard !exercises.isEmpty else { return nil }
            return SMWorkoutContinuation(introSoundKey: nil, interactionUnlockSoundKey: "", exercises: exercises)
        }
        let workout = SMWorkout(
            id: "",
            name: name,
            workoutIntro: nil,
            soundtrack: nil,
            exercises: exercises,
            workoutClosure:nil,
            continuation: continuation
        )
        do{
            try SMKitUIModel.startWorkout(
                viewController: viewController,
                workout: workout,
                delegate: self,
                showPhoneCalibration: DemoSettingsStore.shared.showPhoneCalibration
            )
        }catch{
            showAlert(title: error.localizedDescription)
        }
    }

    func buildWorkoutWasPressed(){
        let builder = BuildWorkoutViewController()
        builder.delegate = self
        let nav = UINavigationController(rootViewController: builder)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    func uiSettingsWasPressed() {
        let settingsVC = UISettingsViewController()
        let nav = UINavigationController(rootViewController: settingsVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    func startProgramWasPressed(){
        DemoSettingsStore.shared.applyToSDK()
        let workoutConfig = WorkoutConfig(
            week: 6, // The program week
            bodyZone: .FullBody, // The program bodyZone
            difficultyLevel: .HighDifficulty, // The program difficulty
            workoutDuration: .Short, // The program duration
            programID: "YOUR_PROGRAM_ID"
        )


        SMKitUIModel.startWorkoutFromProgram(viewController: self, workoutConfig: workoutConfig, delegate: self) { error in
            self.showAlert(title: error.localizedDescription)
        }
    }
    
    func showAlert(title:String, message:String? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func startAssessmentWasPressed(){
        DemoSettingsStore.shared.applyToSDK()
        do{
            let userData = UserData(gender: .Female, birthday: Date()) // This is optinal if not provided the SDK will requst from the user his age and gender
            SMKitUIModel.setFeedbacksUIToExclude(feedbacksUIToExclude: [.pushupKneesOnFloor])
            //Start a Assessment workout with AssessmentTypes
            try SMKitUIModel.startAssessmet(
                viewController: self,
                type: AssessmentTypes.Fitness,
                userData: userData,
                delegate: self,
                onFailure: { error in
                    
                },
                showPhoneCalibration: DemoSettingsStore.shared.showPhoneCalibration
            )
        }catch{
            showAlert(title: error.localizedDescription)
        }
    }
    
    func startCustomAssessmet(){
        DemoSettingsStore.shared.applyToSDK()
        // For target-based mode to work, ScoringParams must include:
        // - targetReps for dynamic exercises (like High Knees)
        // - targetTime for static exercises (like Plank, Squat Static)
        let dynamicScoringParams = ScoringParams(type: .reps, scoreFactor: 0.8, targetTime: nil, targetReps: 10, targetRom: nil)
        let staticScoringParams = ScoringParams(type: .time, scoreFactor: 0.8, targetTime: 10, targetReps: 0, targetRom: nil)
        
        // Uncomment the line below to enable target-based exercise ending:
        // SMKitUIModel.setEndExercisePreferences(endExercisePreferences: .TargetBased)
        
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
                summaryTitle: "Plank High Static",
                summarySubTitle: "This a subtitle",
                summaryTitleMainMetric: "Time",
                scoringParams: staticScoringParams
            )
        ]
        let assessment = SMWorkoutAssessment (
            id: "",
            name: "TEST",
            workoutIntro: intro,
            soundtrack: soundtrack,
            assessmentsExercises: exercises,
            workoutClosure:nil // Custom sound
        )
        
        do{
            try SMKitUIModel.startCustomAssessment(
                viewController: self,
                assessment: assessment,
                delegate: self,
                onFailure: { error in
                    self.showAlert(title: error.localizedDescription)
                },
                showPhoneCalibration: DemoSettingsStore.shared.showPhoneCalibration
            )
        }catch{
            showAlert(title: error.localizedDescription)
        }
    }
}

extension ViewController:AuthManagerDelegate{
    func didFailAuth() {
        self.showAlert(title: "Failed to connect to Sency Server", message: "Please check network connection and try again.")
    }
}

extension ViewController: BuildWorkoutViewControllerDelegate {
    func buildWorkoutViewController(
        _ controller: BuildWorkoutViewController,
        didStartWorkout exercises: [BuiltWorkoutExercise],
        continuationExercises: [BuiltWorkoutExercise]
    ) {
        let mainExercises = exercises.map { makeExercise(from: $0) }
        let continuation = continuationExercises.map { makeExercise(from: $0) }
        let knownDetectors = Array(Set((exercises + continuationExercises).map(\.detector))).sorted()
        SMKitUIModel.jinniAvailableMovementDetectors = knownDetectors
        startWorkout(
            from: controller,
            named: "SMKitUI Build Workout",
            exercises: mainExercises,
            continuationExercises: DemoSettingsStore.shared.enableWorkoutContinuation ? continuation : []
        )
    }
}

extension ViewController:SMKitUIWorkoutDelegate{
    //If there is an error during runtime, it will be received here.
    func handleWorkoutErrors(error: Error) {
        
    }
    //When the user finishes the workout, this function will be called.
    func workoutDidFinish() {
        //Will close SMKitUI.
        SMKitUIModel.exitSDK()
    }
    //When the user exits the workout before finishing, this function will be called.
    func didExitWorkout() {
        //Will close SMKitUI.
        SMKitUIModel.exitSDK()
    }
    
    //When the user finish a exercise this function will be called with the exercise data.
    func exerciseDidFinish(data: ExerciseData) {
    }
    
    // When the summary is avilable this function will be called.
    func didReceiveSummaryData(data: WorkoutSummaryData?) {
    }
}

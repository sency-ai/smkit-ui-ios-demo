//
//  ViewController.swift
//  SMKitUIDemoApp
//
//  Created by netanel-yerushalmi on 18/03/2024.
//

import SwiftUI
import SMKitUI
import SMBase

class ViewController: UIViewController {

    lazy var mainView:UIView = {
        guard let view = UIHostingController(rootView: MainView(
            startWasPressed: startWasPressed,
            startAssessmentWasPressed: startAssessmentWasPressed,
            startCustomAssessmet: startCustomAssessmet
        )).view else {return UIView()}
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AuthManager.shared.delegate = self

        self.view.addSubview(mainView)
        NSLayoutConstraint.activate([
            mainView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            mainView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            mainView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            mainView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
        ])
    }

    func startWasPressed(){
        let intro = Bundle.main.path(forResource: "customWorkoutIntro", ofType: "mp3")
        let soundtrack = Bundle.main.path(forResource: "full-body-long", ofType: "mp3")
        let exercises:[SMExercise] = [
            .init(
                name: "High Knees",
                exerciseIntro: nil, // Custom sound,
                totalSeconds: 30,
                videoInstruction: Bundle.main.path(forResource: "HighKnees", ofType: "mp4"),
                uiElements: [.repsCounter, .timer],
                detector: "HighKnees",
                exerciseClosure: nil // Custom sound
            ),
            .init(
                name: "Squat Regular Static",
                exerciseIntro: nil, // Custom sound,
                totalSeconds: 30,
                videoInstruction: Bundle.main.path(forResource: "SquatRegularStatic", ofType: "mp4"),
                uiElements: [.gaugeOfMotion, .timer],
                detector: "SquatRegularStatic",
                exerciseClosure: nil // Custom sound
            ),
            .init(
                name: "Plank High Static",
                exerciseIntro: nil, // Custom sound,
                totalSeconds: 30,
                videoInstruction: Bundle.main.path(forResource: "PlankHighStatic", ofType: "mp4"),
                uiElements: [.repsCounter, .timer],
                detector: "PlankHighStatic",
                exerciseClosure: nil // Custom sound
            )
        ]
        let workout = SMWorkout(
            id: "",
            name: "TEST",
            workoutIntro: intro,
            soundtrack: soundtrack,
            exercises: exercises,
            workoutClosure:nil // Custom sound
        )
        
        let modifications: [String: Any] = [:]
        do{
            try SMKitUIModel.startWorkout(viewController: self, workout: workout, delegate: self, modifications: modifications)
        }catch{
            print("error")
        }
    }
    
    func startProgramWasPressed(){
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
        do{
            let userData = UserData(gender: .Female, birthday: Date()) // This is optinal if not provided the SDK will requst from the user his age and gender
            SMKitUIModel.setFeedbacksUIToExclude(feedbacksUIToExclude: [.pushupKneesOnFloor])
            //Start a Assessment workout with AssessmentTypes
            try SMKitUIModel.startAssessmet(viewController: self, type: AssessmentTypes.Fitness, userData: userData, delegate: self, onFailure: { error in
                
            })
        }catch{
            showAlert(title: error.localizedDescription)
        }
    }
    
    func startCustomAssessmet(){
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
        
        let modifications: [String: Any] = [:]
        do{
            try SMKitUIModel.startCustomAssessment(viewController: self, assessment: assessment, delegate: self, onFailure:  { error in
                self.showAlert(title: error.localizedDescription)
            }, modifications: modifications.isEmpty ? nil : modifications)
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

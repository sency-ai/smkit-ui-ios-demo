//
//  ViewController.swift
//  SMKitUIDemoApp
//
//  Created by netanel-yerushalmi on 18/03/2024.
//

import SwiftUI
import AVFoundation
import SMKitUI
import SMKit
import SMBase

class ViewController: UIViewController {
    private static let demoAssessmentExercises: [DemoAssessmentExerciseSpec] = [
        .init(
            detector: "StandingSideBendRight",
            title: "Standing Side Bend Right",
            subtitle: "Right lateral flexion",
            scoringType: .rom,
            targetRom: "StandingSideBendLateralTorsoFlex",
            side: .right,
            internalInsightsKey: "StandingSideBend"
        ),
        .init(
            detector: "StandingSideBendLeft",
            title: "Standing Side Bend Left",
            subtitle: "Left lateral flexion",
            scoringType: .rom,
            targetRom: "StandingSideBendLateralTorsoFlex",
            side: .left,
            internalInsightsKey: "StandingSideBend"
        ),
        .init(
            detector: "SquatRegularOverheadStatic",
            title: "OHS Static",
            subtitle: "Overhead squat hold",
            scoringType: .rom,
            targetRom: "SquatHipCreaseDepth",
            internalInsightsKey: "SquatRegularOverheadStatic"
        ),
        .init(
            detector: "HipExternalRotationRight",
            title: "Hip External Rotation Right",
            subtitle: "Right hip mobility",
            scoringType: .rom,
            targetRom: "HipExternalRotationArmsToTheSide",
            side: .right,
            internalInsightsKey: "HipExternalRotation"
        ),
        .init(
            detector: "HipExternalRotationLeft",
            title: "Hip External Rotation Left",
            subtitle: "Left hip mobility",
            scoringType: .rom,
            targetRom: "HipExternalRotationArmsToTheSide",
            side: .left,
            internalInsightsKey: "HipExternalRotation"
        ),
        .init(
            detector: "HipInternalRotationRight",
            title: "Hip Internal Rotation Right",
            subtitle: "Right hip mobility",
            scoringType: .rom,
            targetRom: "HipInternalRotationRotationScore",
            side: .right,
            internalInsightsKey: "HipInternalRotation"
        ),
        .init(
            detector: "HipInternalRotationLeft",
            title: "Hip Internal Rotation Left",
            subtitle: "Left hip mobility",
            scoringType: .rom,
            targetRom: "HipInternalRotationRotationScore",
            side: .left,
            internalInsightsKey: "HipInternalRotation"
        ),
        .init(
            detector: "PlankHighStatic",
            title: "High Plank",
            subtitle: "Full-body plank hold",
            scoringType: .time,
            duration: 60,
            targetTime: 60
        )
    ]

    private var isRunningDemoAssessment = false
    private var isCompletingDemoAssessment = false
    private var pendingDemoAssessmentSummary: WorkoutSummaryData?
    private var didOverrideDemoAssessmentSkeletonStyle = false
    private var demoAssessmentOutroPlayer: AVAudioPlayer?

    lazy var mainView:UIView = {
        guard let view = UIHostingController(rootView: MainView(
            buildWorkoutWasPressed: buildWorkoutWasPressed,
            buildAssessmentWasPressed: buildAssessmentWasPressed,
            startAssessmentWasPressed: startAssessmentWasPressed,
            startCustomAssessmet: startCustomAssessmet,
            summaryHistoryItemWasPressed: summaryHistoryItemWasPressed,
            guidanceModeWasPressed: guidanceModeWasPressed,
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

    private func makeExercise(from assessmentExercise: BuiltAssessmentExercise) -> SMExercise {
        SMExercise(
            name: assessmentExercise.entry.displayName,
            exerciseIntro: nil,
            totalSeconds: assessmentExercise.duration,
            videoInstruction: assessmentExercise.entry.videoInstruction,
            uiElements: nil,
            detector: assessmentExercise.entry.detector,
            exerciseClosure: nil
        )
    }

    private func makeAssessmentExercise(
        from config: BuiltAssessmentExercise,
        targetRepsProgress: Bool
    ) -> SMAssessmentExercise {
        let scoringParams: ScoringParams
        let uiElements: Set<UIElement>?
        let showTargetProgress: Bool

        switch config.scoringMode {
        case .reps:
            scoringParams = ScoringParams(
                type: .reps,
                scoreFactor: 0.5,
                targetTime: nil,
                targetReps: config.targetReps,
                targetRom: nil
            )
            uiElements = targetRepsProgress ? [.repsCounter] : nil
            showTargetProgress = targetRepsProgress
        case .time:
            scoringParams = ScoringParams(
                type: .time,
                scoreFactor: 0.5,
                targetTime: config.targetTime,
                targetReps: nil,
                targetRom: nil
            )
            uiElements = nil
            showTargetProgress = false
        case .rom:
            scoringParams = ScoringParams(
                type: .rom,
                scoreFactor: 0.5,
                targetTime: nil,
                targetReps: nil,
                targetRom: config.entry.targetRom ?? ""
            )
            uiElements = nil
            showTargetProgress = false
        }

        return SMAssessmentExercise(
            name: config.entry.displayName,
            exerciseIntro: nil,
            totalSeconds: config.duration,
            videoInstruction: config.entry.videoInstruction,
            uiElements: uiElements,
            detector: config.entry.detector,
            exerciseClosure: nil,
            summaryTitle: config.entry.displayName,
            summarySubTitle: config.entry.kind.title,
            summaryTitleMainMetric: config.scoringMode.title,
            scoringParams: scoringParams,
            showTargetProgress: showTargetProgress
        )
    }

    private func makeDemoAssessmentExercise(
        from spec: DemoAssessmentExerciseSpec,
        guidanceModeEnabled: Bool
    ) -> SMAssessmentExercise {
        let scoringParams = ScoringParams(
            type: spec.scoringType,
            scoreFactor: 0.5,
            targetTime: spec.targetTime,
            targetReps: nil,
            targetRom: spec.targetRom
        )
        let exercise = SMAssessmentExercise(
            name: spec.title,
            exerciseIntro: nil,
            totalSeconds: spec.duration,
            videoInstruction: "\(spec.detector)InstructionVideo",
            uiElements: spec.uiElements,
            detector: spec.detector,
            exerciseClosure: nil,
            summaryTitle: spec.title,
            summarySubTitle: spec.subtitle,
            summaryTitleMainMetric: spec.scoringType.summaryTitle,
            scoringParams: scoringParams,
            internalInsightsKey: spec.internalInsightsKey
        )
        exercise.guidanceMode = guidanceModeEnabled
        exercise.side = spec.side
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

    func buildAssessmentWasPressed() {
        let builder = BuildAssessmentViewController()
        builder.delegate = self
        let nav = UINavigationController(rootViewController: builder)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    func guidanceModeWasPressed() {
        let guidance = GuidanceModeViewController()
        guidance.delegate = self
        let nav = UINavigationController(rootViewController: guidance)
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
        let picker = BuiltInAssessmentViewController()
        picker.delegate = self
        let nav = UINavigationController(rootViewController: picker)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    private func startBuiltInAssessment(type: AssessmentTypes, from viewController: UIViewController) {
        DemoSettingsStore.shared.applyToSDK()
        do{
            let userData = UserData(gender: .Female, birthday: Date()) // This is optinal if not provided the SDK will requst from the user his age and gender
            SMKitUIModel.setFeedbacksUIToExclude(feedbacksUIToExclude: [.pushupKneesOnFloor])
            //Start a Assessment workout with AssessmentTypes
            try SMKitUIModel.startAssessmet(
                viewController: viewController,
                type: type,
                userData: userData,
                delegate: self,
                onFailure: { [weak self] error in
                    self?.showAlert(title: error.localizedDescription)
                },
                showPhoneCalibration: DemoSettingsStore.shared.showPhoneCalibration
            )
        }catch{
            showAlert(title: error.localizedDescription)
        }
    }
    
    func startCustomAssessmet(guidanceModeEnabled: Bool = true){
        DemoSettingsStore.shared.applyToSDK()
        applyDemoAssessmentSkeletonStyle()
        SMKitUIModel.setEndExercisePreferences(endExercisePreferences: .Default)
        isRunningDemoAssessment = true
        isCompletingDemoAssessment = false
        pendingDemoAssessmentSummary = nil
        demoAssessmentOutroPlayer?.stop()
        demoAssessmentOutroPlayer = nil

        let intro = Bundle.main.path(forResource: "FutureIntro", ofType: "mp3")
        let exercises = Self.demoAssessmentExercises.map {
            makeDemoAssessmentExercise(from: $0, guidanceModeEnabled: guidanceModeEnabled)
        }
        let assessment = SMWorkoutAssessment (
            id: "future-assessment",
            name: "Future Assessment",
            workoutIntro: intro,
            soundtrack: nil,
            assessmentsExercises: exercises,
            workoutClosure: nil,
            exportInternalInsights: true
        )
        
        do{
            try SMKitUIModel.startCustomAssessment(
                viewController: self,
                assessment: assessment,
                userData: nil,
                forceShowUserDataScreen: true,
                showSummary: false,
                delegate: self,
                onFailure: { [weak self] error in
                    self?.resetDemoAssessmentState()
                    self?.showAlert(title: error.localizedDescription)
                },
                showPhoneCalibration: DemoSettingsStore.shared.showPhoneCalibration
            )
        }catch{
            resetDemoAssessmentState()
            showAlert(title: error.localizedDescription)
        }
    }

    private func resetDemoAssessmentState() {
        restoreDemoAssessmentSkeletonStyleIfNeeded()
        isRunningDemoAssessment = false
        isCompletingDemoAssessment = false
        pendingDemoAssessmentSummary = nil
    }

    private func applyDemoAssessmentSkeletonStyle() {
        didOverrideDemoAssessmentSkeletonStyle = true
        SMKitUIModel.skeletonHidden = false
        SMKitUIModel.skeletonPreset = .minimalDots
        SMKitUIModel.skeletonConnectionStyle = .none
        SMKitUIModel.skeletonJointShape = .circle
        SMKitUIModel.skeletonDotsOpacity = 1
        SMKitUIModel.skeletonConnectionsOpacity = 0
        SMKitUIModel.skeletonDotsInnerColorOption = nil
        SMKitUIModel.skeletonDotsOuterColorOption = nil
        SMKitUIModel.skeletonDotsGlow = 1
        SMKitUIModel.skeletonLineWidthScale = 0.5
        SMKitUIModel.skeletonSoftness = 0
    }

    private func restoreDemoAssessmentSkeletonStyleIfNeeded() {
        guard didOverrideDemoAssessmentSkeletonStyle else { return }
        didOverrideDemoAssessmentSkeletonStyle = false
        DemoSettingsStore.shared.applyToSDK()
    }

    private func playDemoAssessmentOutro() {
        guard let url = Bundle.main.url(forResource: "FutureOutro", withExtension: "mp3") else {
            return
        }

        do {
            demoAssessmentOutroPlayer?.stop()
            demoAssessmentOutroPlayer = try AVAudioPlayer(contentsOf: url)
            demoAssessmentOutroPlayer?.prepareToPlay()
            demoAssessmentOutroPlayer?.play()
        } catch {
            print("Unable to play Future Assessment outro: \(error.localizedDescription)")
        }
    }

    private func recordAndPresentPendingDemoAssessmentSummaryAfterSDKExit() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.recordAndPresentPendingDemoAssessmentSummary()
        }
    }

    private func recordAndPresentPendingDemoAssessmentSummary() {
        guard isRunningDemoAssessment else { return }
        let summary = pendingDemoAssessmentSummary
        let item = makeDemoAssessmentSummaryHistoryItem(summary: summary)
        DemoAssessmentSummaryHistoryStore.shared.add(item)
        resetDemoAssessmentState()
        presentDemoAssessmentSummary(summary, playOutro: true)
    }

    private func makeDemoAssessmentSummaryHistoryItem(summary: WorkoutSummaryData?) -> DemoAssessmentSummaryHistoryItem {
        DemoAssessmentSummaryHistoryItem(
            completedAt: Date(),
            summary: summary,
            score: demoAssessmentScore(for: summary),
            completedCount: demoAssessmentCompletedCount(for: summary),
            totalCount: Self.demoAssessmentExercises.count,
            duration: summary?.totalTime ?? 0
        )
    }

    private func demoAssessmentScore(for summary: WorkoutSummaryData?) -> Int? {
        if let score = summary?.scoreSegmented ?? summary?.score {
            return score
        }

        let scores = Self.demoAssessmentExercises.compactMap { spec -> Float? in
            guard let data = demoAssessmentData(for: spec, in: summary),
                  isDemoAssessmentExerciseCompleted(data, spec: spec) else {
                return nil
            }
            return data.totalScoreSegmented ?? data.totalScore
        }
        guard !scores.isEmpty else { return nil }
        return Int(scores.reduce(0, +) / Float(scores.count))
    }

    private func demoAssessmentCompletedCount(for summary: WorkoutSummaryData?) -> Int {
        Self.demoAssessmentExercises
            .filter { spec in
                guard let data = demoAssessmentData(for: spec, in: summary) else { return false }
                return isDemoAssessmentExerciseCompleted(data, spec: spec)
            }
            .count
    }

    private func demoAssessmentData(for spec: DemoAssessmentExerciseSpec, in summary: WorkoutSummaryData?) -> ExerciseData? {
        summary?.exercises.first {
            $0.exerciseId == spec.detector ||
            $0.name == spec.detector ||
            $0.name == spec.title ||
            $0.prettyName == spec.title
        }
    }

    private func isDemoAssessmentExerciseCompleted(_ data: ExerciseData, spec: DemoAssessmentExerciseSpec) -> Bool {
        if let timeInPosition = demoAssessmentEffectiveTimeInPosition(for: data) {
            guard timeInPosition >= spec.minimumCompletionTimeInPosition else { return false }

            if spec.scoringType == .rom {
                return hasCompletedDemoAssessmentRom(data, spec: spec)
            }

            return true
        }

        if spec.scoringType == .reps, let dynamicData = data as? ExerciseDynamicData {
            return dynamicData.dynamicInfo?.performedReps.isEmpty == false || (data.repsPerformed ?? 0) > 0
        }

        return false
    }

    private func hasCompletedDemoAssessmentRom(_ data: ExerciseData, spec: DemoAssessmentExerciseSpec) -> Bool {
        let peakRomScore = data.peakRangeOfMotionScore ?? 0
        let sustainedRomScore = data.performanceScoreSegmented ?? data.performanceScore ?? 0
        return peakRomScore >= spec.minimumCompletionRomScore &&
            sustainedRomScore >= spec.minimumCompletionRomScore
    }

    private func demoAssessmentEffectiveTimeInPosition(for data: ExerciseData) -> Double? {
        if let timeInPosition = data.timeInPosition {
            return timeInPosition
        }

        if let staticData = data as? ExerciseStaticData,
           let staticInfo = staticData.staticInfo {
            return staticInfo.timeInPosition
        }

        return nil
    }

    private func summaryHistoryItemWasPressed(_ item: DemoAssessmentSummaryHistoryItem) {
        presentDemoAssessmentSummary(item.summary)
    }

    private func presentDemoAssessmentSummary(_ summary: WorkoutSummaryData?, playOutro: Bool = false) {
        let summaryView = DemoAssessmentSummaryView(
            summary: summary,
            plannedExercises: Self.demoAssessmentExercises
        ) { [weak self] in
            self?.dismiss(animated: true)
        }
        let hostingController = UIHostingController(rootView: summaryView)
        hostingController.modalPresentationStyle = .pageSheet
        if let sheet = hostingController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }

        let onPresented = { [weak self] in
            guard playOutro else { return }
            self?.playDemoAssessmentOutro()
        }

        if presentedViewController == nil {
            present(hostingController, animated: true, completion: onPresented)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.present(hostingController, animated: true, completion: onPresented)
            }
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
        startWorkout(
            from: controller,
            named: "SMKitUI Build Workout",
            exercises: mainExercises,
            continuationExercises: DemoSettingsStore.shared.enableWorkoutContinuation ? continuation : []
        )
    }
}

extension ViewController: BuildAssessmentViewControllerDelegate {
    func buildAssessmentViewController(
        _ controller: BuildAssessmentViewController,
        didStartAssessment exercises: [BuiltAssessmentExercise],
        targetRepsProgress: Bool
    ) {
        DemoSettingsStore.shared.applyToSDK()
        SMKitUIModel.setEndExercisePreferences(
            endExercisePreferences: targetRepsProgress ? .TargetBased : .Default
        )

        let assessment = SMWorkoutAssessment(
            id: "built-assessment",
            name: "Built Assessment",
            workoutIntro: nil,
            soundtrack: nil,
            assessmentsExercises: exercises.map {
                makeAssessmentExercise(from: $0, targetRepsProgress: targetRepsProgress)
            },
            workoutClosure: nil
        )

        do {
            try SMKitUIModel.startCustomAssessment(
                viewController: controller,
                assessment: assessment,
                userData: UserData(gender: .Other, birthday: Date()),
                delegate: self,
                onFailure: { [weak self] error in
                    self?.showAlert(title: error.localizedDescription)
                },
                showPhoneCalibration: DemoSettingsStore.shared.showPhoneCalibration
            )
        } catch {
            showAlert(title: error.localizedDescription)
        }
    }

    func buildAssessmentViewController(
        _ controller: BuildAssessmentViewController,
        didStartRepTimerWorkout exercises: [BuiltAssessmentExercise]
    ) {
        startWorkout(
            from: controller,
            named: "Rep Timer Assessment",
            exercises: exercises.map { makeExercise(from: $0) }
        )
    }
}

extension ViewController: BuiltInAssessmentViewControllerDelegate {
    func builtInAssessmentViewController(
        _ controller: BuiltInAssessmentViewController,
        didSelect type: AssessmentTypes
    ) {
        startBuiltInAssessment(type: type, from: controller)
    }
}

extension ViewController: GuidanceModeViewControllerDelegate {
    func guidanceModeViewController(
        _ controller: GuidanceModeViewController,
        didStart detector: String
    ) {
        let exercise = SMExercise(
            name: ExerciseCatalog.displayName(for: detector),
            exerciseIntro: nil,
            totalSeconds: max(10, ExerciseCatalog.entry(for: detector).defaultDuration),
            videoInstruction: "\(detector)InstructionVideo",
            uiElements: nil,
            detector: detector,
            exerciseClosure: nil
        )
        exercise.guidanceMode = true
        startWorkout(
            from: controller,
            named: "Guidance Mode",
            exercises: [exercise]
        )
    }
}

extension ViewController:SMKitUIWorkoutDelegate{
    //If there is an error during runtime, it will be received here.
    func handleWorkoutErrors(error: Error) {
        if isRunningDemoAssessment {
            resetDemoAssessmentState()
        }
    }
    //When the user finishes the workout, this function will be called.
    func workoutDidFinish() {
        let shouldShowDemoSummary = isRunningDemoAssessment
        if shouldShowDemoSummary {
            isCompletingDemoAssessment = true
        }
        //Will close SMKitUI.
        SMKitUIModel.exitSDK()
        if shouldShowDemoSummary {
            recordAndPresentPendingDemoAssessmentSummaryAfterSDKExit()
        }
    }
    //When the user exits the workout before finishing, this function will be called.
    func didExitWorkout() {
        if isCompletingDemoAssessment {
            return
        }

        resetDemoAssessmentState()
        //Will close SMKitUI.
        SMKitUIModel.exitSDK()
    }
    
    //When the user finish a exercise this function will be called with the exercise data.
    func exerciseDidFinish(data: ExerciseData) {
    }
    
    // When the summary is avilable this function will be called.
    func didReceiveSummaryData(data: WorkoutSummaryData?) {
        if isRunningDemoAssessment {
            pendingDemoAssessmentSummary = data
        }
    }
}

private struct DemoAssessmentExerciseSpec: Identifiable {
    let id: String
    let detector: String
    let title: String
    let subtitle: String
    let scoringType: ScoringType
    let targetRom: String?
    let duration: Int
    let targetTime: Int
    let side: ExerciseSide?
    let uiElements: Set<UIElement>
    let internalInsightsKey: String?
    let minimumCompletionTimeInPosition: Double
    let minimumCompletionRomScore: Float

    init(
        detector: String,
        title: String,
        subtitle: String,
        scoringType: ScoringType,
        targetRom: String? = nil,
        duration: Int = 15,
        targetTime: Int = 15,
        side: ExerciseSide? = nil,
        uiElements: Set<UIElement>? = nil,
        internalInsightsKey: String? = nil,
        minimumCompletionTimeInPosition: Double = 3,
        minimumCompletionRomScore: Float? = nil
    ) {
        self.id = detector
        self.detector = detector
        self.title = title
        self.subtitle = subtitle
        self.scoringType = scoringType
        self.targetRom = targetRom
        self.duration = duration
        self.targetTime = targetTime
        self.side = side
        self.uiElements = uiElements ?? (detector == "PlankHighStatic" ? [.timer, .holdingPosition] : [.timer, .gaugeOfMotion])
        self.internalInsightsKey = internalInsightsKey
        self.minimumCompletionTimeInPosition = minimumCompletionTimeInPosition
        self.minimumCompletionRomScore = minimumCompletionRomScore ?? (scoringType == .rom ? 25 : 0)
    }
}

private extension ScoringType {
    var summaryTitle: String {
        switch self {
        case .rom: return "ROM"
        case .time: return "Hold"
        case .reps: return "Reps"
        @unknown default: return rawValue.capitalized
        }
    }
}

private struct DemoAssessmentSummaryView: View {
    let summary: WorkoutSummaryData?
    let plannedExercises: [DemoAssessmentExerciseSpec]
    let onDone: () -> Void
    @State private var selectedInsightsDetail: DemoExerciseInsightsDetail?

    private var overallScore: Int? {
        let scores = plannedExercises.compactMap { spec -> Float? in
            guard let data = data(for: spec), isCompleted(data, spec: spec) else { return nil }
            return data.totalScoreSegmented ?? data.totalScore
        }
        guard !scores.isEmpty else { return nil }
        return Int(scores.reduce(0, +) / Float(scores.count))
    }

    private var completedCount: Int {
        plannedExercises
            .filter { spec in
                guard let data = data(for: spec) else { return false }
                return isCompleted(data, spec: spec)
            }
            .count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    stats
                    exerciseList
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Assessment Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDone)
                        .fontWeight(.semibold)
                }
            }
        }
        .overlay {
            ZStack {
                if let selectedInsightsDetail {
                    InsightsDetailPopup(detail: selectedInsightsDetail) {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            self.selectedInsightsDetail = nil
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
            }
        }
        .animation(.easeInOut(duration: 0.18), value: selectedInsightsDetail?.id)
    }

    private var header: some View {
        HStack(spacing: 18) {
            ProgressRing(score: overallScore)
                .frame(width: 92, height: 92)

            VStack(alignment: .leading, spacing: 8) {
                Text("Future Assessment")
                    .font(.title2.weight(.bold))
                Text(summary == nil ? "Summary data was not returned." : "Assessment completed across the movement sequence.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(uiColor: .systemTeal).opacity(0.18),
                            Color(uiColor: .systemOrange).opacity(0.12),
                            Color(uiColor: .systemBackground)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }

    private var stats: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatTile(title: "Completed", value: "\(completedCount)/\(plannedExercises.count)", systemImage: "checkmark.circle.fill")
            StatTile(title: "Score", value: scoreText(overallScore), systemImage: "gauge.medium")
            StatTile(title: "Duration", value: totalTimeText, systemImage: "clock.fill")
            StatTile(title: "Type", value: "Assessment", systemImage: "figure.walk")
        }
    }

    private var exerciseList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Movement Results")
                .font(.headline)

            ForEach(plannedExercises) { spec in
                exerciseResultRow(for: spec)
            }
        }
    }

    private var totalTimeText: String {
        guard let summary, summary.totalTime > 0 else { return "--" }
        let seconds = Int(summary.totalTime.rounded())
        let minutes = seconds / 60
        let remainder = seconds % 60
        return minutes > 0 ? "\(minutes)m \(remainder)s" : "\(remainder)s"
    }

    private func data(for spec: DemoAssessmentExerciseSpec) -> ExerciseData? {
        summary?.exercises.first {
            $0.exerciseId == spec.detector ||
            $0.name == spec.detector ||
            $0.name == spec.title ||
            $0.prettyName == spec.title
        }
    }

    private func exerciseResultRow(for spec: DemoAssessmentExerciseSpec) -> some View {
        let exerciseData = data(for: spec)
        let insightsDetail: DemoExerciseInsightsDetail?
        let isComplete: Bool
        let score: Int?
        if let exerciseData {
            isComplete = self.isCompleted(exerciseData, spec: spec)
            score = isComplete ? scoreValue(exerciseData.totalScoreSegmented ?? exerciseData.totalScore) : nil
            insightsDetail = self.insightsDetail(for: exerciseData, spec: spec, isComplete: isComplete)
        } else {
            isComplete = false
            score = nil
            insightsDetail = nil
        }
        return ExerciseResultRow(
            title: spec.title,
            subtitle: spec.subtitle,
            metric: metricText(for: spec),
            score: score,
            isComplete: isComplete,
            insightCount: insightsDetail?.entries.count ?? 0
        ) {
            guard let insightsDetail else { return }
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedInsightsDetail = insightsDetail
            }
        }
    }

    private func isCompleted(_ data: ExerciseData, spec: DemoAssessmentExerciseSpec) -> Bool {
        if let timeInPosition = effectiveTimeInPosition(for: data) {
            guard timeInPosition >= spec.minimumCompletionTimeInPosition else { return false }

            if spec.scoringType == .rom {
                return hasCompletedRom(data, spec: spec)
            }

            return true
        }

        if spec.scoringType == .reps, let dynamicData = data as? ExerciseDynamicData {
            return dynamicData.dynamicInfo?.performedReps.isEmpty == false || (data.repsPerformed ?? 0) > 0
        }

        return false
    }

    private func hasCompletedRom(_ data: ExerciseData, spec: DemoAssessmentExerciseSpec) -> Bool {
        let peakRomScore = data.peakRangeOfMotionScore ?? 0
        let sustainedRomScore = data.performanceScoreSegmented ?? data.performanceScore ?? 0
        return peakRomScore >= spec.minimumCompletionRomScore &&
            sustainedRomScore >= spec.minimumCompletionRomScore
    }

    private func effectiveTimeInPosition(for data: ExerciseData) -> Double? {
        if let timeInPosition = data.timeInPosition {
            return timeInPosition
        }

        if let staticData = data as? ExerciseStaticData,
           let staticInfo = staticData.staticInfo {
            return staticInfo.timeInPosition
        }

        return nil
    }

    private func insightsDetail(for data: ExerciseData, spec: DemoAssessmentExerciseSpec, isComplete: Bool) -> DemoExerciseInsightsDetail? {
        guard isComplete,
              hasRelevantScoring(data, spec: spec),
              let internalInsights = data.internalInsights,
              !internalInsights.entries.isEmpty else {
            return nil
        }
        return DemoExerciseInsightsDetail(
            title: spec.title,
            subtitle: spec.subtitle,
            entries: internalInsights.entries
        )
    }

    private func hasRelevantScoring(_ data: ExerciseData, spec: DemoAssessmentExerciseSpec) -> Bool {
        switch spec.scoringType {
        case .rom:
            return data.peakRangeOfMotionScore != nil ||
                data.peakRangeOfMotionDegrees != nil ||
                data.totalScoreSegmented != nil ||
                data.totalScore != nil
        case .time:
            return effectiveTimeInPosition(for: data) != nil ||
                data.timeInPositionPerfect != nil ||
                data.totalScoreSegmented != nil ||
                data.totalScore != nil
        case .reps:
            return data.repsPerformed != nil ||
                data.repsPerformedPerfect != nil ||
                data.totalScoreSegmented != nil ||
                data.totalScore != nil
        @unknown default:
            return data.totalScoreSegmented != nil || data.totalScore != nil
        }
    }

    private func metricText(for spec: DemoAssessmentExerciseSpec) -> String {
        guard let data = data(for: spec) else { return "No data" }
        guard isCompleted(data, spec: spec) else { return "No data" }

        switch spec.scoringType {
        case .rom:
            if let rom = data.peakRangeOfMotionScore {
                return "\(Int(rom.rounded()))% ROM"
            }
        case .time:
            if let time = effectiveTimeInPosition(for: data) {
                return "\(Int(time.rounded()))s hold"
            }
        case .reps:
            if let reps = data.repsPerformed {
                return "\(reps) reps"
            }
        @unknown default:
            break
        }

        if let score = scoreValue(data.totalScoreSegmented ?? data.totalScore ?? data.performanceScore) {
            return "\(score)/100"
        }
        return isCompleted(data, spec: spec) ? "Completed" : "No data"
    }

    private func scoreText(_ score: Int?) -> String {
        guard let score else { return "--" }
        return "\(score)/100"
    }

    private func scoreValue(_ score: Float?) -> Int? {
        guard let score else { return nil }
        return Int(score.rounded())
    }
}

private struct ProgressRing: View {
    let score: Int?

    private var progress: Double {
        Double(min(max(score ?? 0, 0), 100)) / 100.0
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [Color(uiColor: .systemTeal), Color(uiColor: .systemGreen)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text(score.map(String.init) ?? "--")
                    .font(.title.bold())
                Text("score")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct StatTile: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(Color(uiColor: .systemTeal))
                .font(.title3)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 72)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}

private struct DemoExerciseInsightsDetail: Identifiable {
    let title: String
    let subtitle: String
    let entries: [AssessmentInternalInsightEntry]

    var id: String {
        title
    }
}

private struct InsightsDetailPopup: View {
    let detail: DemoExerciseInsightsDetail
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.34)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(detail.title)
                            .font(.title3.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                        Text(detail.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 8)

                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close insights")
                }

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(detail.entries.enumerated()), id: \.offset) { _, entry in
                            InsightEntryView(entry: entry)
                        }
                    }
                }
                .frame(maxHeight: 460)
            }
            .padding(20)
            .frame(maxWidth: 540)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.22), radius: 28, x: 0, y: 16)
            .padding(20)
        }
    }
}

private struct InsightEntryView: View {
    let entry: AssessmentInternalInsightEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color(uiColor: .systemTeal))
                    .font(.title3)
                    .frame(width: 26)

                Text(entry.insight)
                    .font(.subheadline.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let impact = entry.impact?.trimmingCharacters(in: .whitespacesAndNewlines), !impact.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Impact")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(impact)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}

private struct ExerciseResultRow: View {
    let title: String
    let subtitle: String
    let metric: String
    let score: Int?
    let isComplete: Bool
    let insightCount: Int
    let onInsightsTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: isComplete ? "checkmark.seal.fill" : "circle.dashed")
                .foregroundStyle(isComplete ? Color(uiColor: .systemGreen) : Color(uiColor: .systemGray))
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .truncationMode(.tail)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            if insightCount > 0 {
                Button(action: onInsightsTap) {
                    Label("\(insightCount)", systemImage: "lightbulb.fill")
                        .font(.caption.weight(.bold))
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(Color(uiColor: .systemTeal))
                .accessibilityLabel("Open internal insights")
            }

            VStack(alignment: .trailing, spacing: 4) {
                Text(metric)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                Text(score.map { "\($0)/100" } ?? "--")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(minWidth: 74, maxWidth: 96, alignment: .trailing)
            .layoutPriority(2)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
}

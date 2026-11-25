//
//  DemoPresets.swift
//  SMKitUIDemoApp
//

import Foundation
import SMKitUI

/// Which home-screen preset is preparing its assets, if any.
final class DemoPresetState: ObservableObject {
    @Published var preparingPreset: String?
}

/// Ready-made workouts started straight from the home screen, for live demos.
enum DemoPresets {
    static let mobilityFlowName = "Mobility Flow"
    static let exampleWorkoutName = "Example workout"

    /// One 10-second hold each: rhomboid stretch, then seated thoracic side
    /// bending to the left and to the right.
    static func mobilityFlow() -> SMWorkout {
        let config = SMMobilityFlowConfig(blocks: [
            SMMobilityFlowBlock(detector: "RhomboidStretch", repetitions: 1, secondsPerRep: 10),
            SMMobilityFlowBlock(detector: "SeatedThoracicSideBendingLeft", repetitions: 1, secondsPerRep: 10),
            SMMobilityFlowBlock(detector: "SeatedThoracicSideBendingRight", repetitions: 1, secondsPerRep: 10)
        ])
        return workout(
            id: "demo-mobility-flow",
            name: mobilityFlowName,
            exercises: [SMExercise(mobilityFlowConfig: config)]
        )
    }

    /// Arnold shoulder press, Jefferson curl in guidance mode, Combo01,
    /// therapy squats, push-ups and 5 standing bow-and-arrow mobility reps.
    /// Every exercise has adaptive ROM feedback, the guidance-mode suggestion,
    /// a rep-count voice every 5 reps and the pre-exercise countdown; push-ups
    /// also play a sound on each rep.
    static func exampleWorkout() -> SMWorkout {
        let jeffersonCurl = exercise("JeffersonCurl", "Jefferson Curl", seconds: 45, uiElements: [.timer, .gaugeOfMotion])
        jeffersonCurl.guidanceMode = true

        // Combo01: a squat, then standing bicycle crunches on each side,
        // with the SDK's default reps per movement.
        let combo = exercise(
            "Combo01",
            "Combo01",
            seconds: 60,
            uiElements: [.repsCounter, .timer],
            instructionVideo: false,
            exerciseIntro: "ComboSequenceIntro"
        )
        combo.targetReps = 4

        // A mobility movement counted as reps instead of a timed hold.
        let bowArrow = exercise(
            "StandingBowArrowThoracicMobilityRight",
            "Standing Bow and Arrow Right",
            seconds: 60,
            uiElements: [.repsCounter, .timer]
        )
        bowArrow.mobilityRepConfig = SMMobilityRepConfig(targetReps: 5)

        return workout(
            id: "demo-showcase",
            name: exampleWorkoutName,
            exercises: [
                exercise("ArnoldShoulderPress", "Arnold Shoulder Press", seconds: 40, uiElements: [.timer, .repsCounter]),
                jeffersonCurl,
                combo,
                // SMKitUI runs the side-view setup, raised-hands check and
                // virtual wall itself.
                exercise("TherapySquat", "Therapy Squat", seconds: 45, uiElements: [.timer, .repsCounter, .gaugeOfMotion]),
                exercise("PushupRegular", "Push-ups", seconds: 40, uiElements: [.repsCounter, .timer], playSoundOnEachRep: true),
                bowArrow
            ]
        )
    }

    private static func workout(id: String, name: String, exercises: [SMExercise]) -> SMWorkout {
        SMWorkout(
            id: id,
            name: name,
            workoutIntro: nil,
            soundtrack: nil,
            exercises: exercises,
            workoutClosure: nil
        )
    }

    private static func exercise(
        _ detector: String,
        _ name: String,
        seconds: Int,
        uiElements: Set<UIElement>,
        instructionVideo: Bool = true,
        exerciseIntro: String? = nil,
        playSoundOnEachRep: Bool = false
    ) -> SMExercise {
        let exercise = SMExercise(
            name: name,
            exerciseIntro: exerciseIntro,
            totalSeconds: seconds,
            // Instruction videos are resolved by detector name, like the demo's other workouts.
            videoInstruction: instructionVideo ? detector : nil,
            uiElements: uiElements,
            detector: detector,
            exerciseClosure: nil,
            playPreExerciseCountdown: true,
            playRepMilestoneVoice: true,
            repMilestoneInterval: 5,
            playSoundOnEachRep: playSoundOnEachRep
        )
        exercise.enableGuidanceModeSuggestion = true
        exercise.adaptiveRomFeedbackEnabled = true
        return exercise
    }
}

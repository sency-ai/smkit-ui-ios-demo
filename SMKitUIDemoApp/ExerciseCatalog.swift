//
//  ExerciseCatalog.swift
//  SMKitUIDemoApp
//

import Foundation
import SMBase
import SMKit
import SMKitUI

enum DemoExerciseKind: Equatable {
    case dynamic
    case `static`
    case mobility
    case bodyAssessment
    case other

    var title: String {
        switch self {
        case .dynamic: return "Dynamic"
        case .static: return "Static"
        case .mobility, .bodyAssessment: return "Mobility"
        case .other: return "Other"
        }
    }

    var supportsRepScoring: Bool {
        self == .dynamic
    }

    var defaultDuration: Int {
        switch self {
        case .dynamic: return 30
        case .static, .mobility, .bodyAssessment, .other: return 10
        }
    }
}

enum DemoExerciseFilter: CaseIterable {
    case all
    case dynamic
    case `static`
    case mobility

    var title: String {
        switch self {
        case .all: return "All"
        case .dynamic: return "Dynamic"
        case .static: return "Static"
        case .mobility: return "Mobility"
        }
    }

    func contains(_ kind: DemoExerciseKind) -> Bool {
        switch self {
        case .all:
            return true
        case .dynamic:
            return kind == .dynamic
        case .static:
            return kind == .static
        case .mobility:
            return kind == .mobility || kind == .bodyAssessment
        }
    }
}

enum DemoAssessmentScoringMode: CaseIterable {
    case reps
    case time
    case rom

    var title: String {
        switch self {
        case .reps: return "Reps"
        case .time: return "Time"
        case .rom: return "ROM"
        }
    }
}

struct DemoExerciseCatalogEntry: Equatable {
    let detector: String
    let kind: DemoExerciseKind
    let assessmentModes: [DemoAssessmentScoringMode]
    let defaultDuration: Int
    let defaultTargetReps: Int
    let defaultTargetTime: Int
    let targetRom: String?

    var displayName: String {
        ExerciseCatalog.displayName(for: detector)
    }

    var defaultAssessmentMode: DemoAssessmentScoringMode {
        assessmentModes.first ?? .time
    }

    var videoInstruction: String {
        "\(detector)InstructionVideo"
    }
}

enum ExerciseCatalog {
    static let defaultTargetReps = 5
    static let defaultTargetTime = 10

    private static let feedbackCatalogDetectors: Set<String> = [
        "AirJumpRope",
        "AlternateWindmillToeTouch",
        "AnkleMobilityLeft",
        "AnkleMobilityRight",
        "BackSuperman",
        "BackSupermanHold",
        "BirdDog",
        "Burpees",
        "ButtKicks",
        "CalfRaises",
        "CalfStretchLungePositionLeft",
        "CalfStretchLungePositionRight",
        "ClamshellsLeft",
        "ClamshellsRight",
        "Crunches",
        "DownwardDogStretch",
        "FastMarchRun",
        "Froggers",
        "GlutesBridge",
        "GlutesBridgeHold",
        "GlutesStretchOnTheFloorLeft",
        "GlutesStretchOnTheFloorRight",
        "GroinAndAdductor",
        "HamstringMobility",
        "HappyBaby",
        "HighKnees",
        "HipExternalRotationFigureFourStretchLeft",
        "HipExternalRotationFigureFourStretchRight",
        "HipExternalRotationLeft",
        "HipExternalRotationRight",
        "HipFlexionLeft",
        "HipFlexionRight",
        "HipFlexorLungeStretchLeft",
        "HipFlexorLungeStretchRight",
        "HipFlexorStretchLeft",
        "HipFlexorStretchRight",
        "HipInternalRotationLeft",
        "HipInternalRotationRight",
        "HollowHold",
        "InnerThighMobility",
        "InternalRotationSideStretchLeft",
        "InternalRotationSideStretchRight",
        "JeffersonCurl",
        "JumpingJacks",
        "Jumps",
        "KneelingQuadStretchLeft",
        "KneelingQuadStretchRight",
        "LatStretchLeft",
        "LatStretchRight",
        "LateralHandRaise",
        "LateralHandRaiseLeft",
        "LateralHandRaiseRight",
        "LateralRaises",
        "LumbarCamelSeated",
        "LumbarCatSeated",
        "LumbarRotationsSeatedLeft",
        "LumbarRotationsSeatedRight",
        "LungeFront",
        "LungeFrontLeft",
        "LungeFrontRight",
        "LungeJumps",
        "LungeRegularStatic",
        "LungeRegularStaticLeft",
        "LungeRegularStaticRight",
        "LungeSide",
        "LungeSideLeft",
        "LungeSideRight",
        "LungeSideStaticLeft",
        "LungeSideStaticRight",
        "OverheadMobility",
        "PlankCommando",
        "PlankHighShoulderTaps",
        "PlankHighStatic",
        "PlankHighToeTaps",
        "PlankJacksHigh",
        "PlankLowHipTwist",
        "PlankLowStatic",
        "PlankSideHighStatic",
        "PlankSideHighStaticLeft",
        "PlankSideHighStaticRight",
        "PlankSideLowStatic",
        "PlankSideLowStaticLeft",
        "PlankSideLowStaticRight",
        "PogoJumps",
        "PowerWalkInPlace",
        "PrayerStretch",
        "PushupKnees",
        "PushupKneesNarrow",
        "PushupKneesRegular",
        "PushupKneesWide",
        "PushupNarrow",
        "PushupRegular",
        "PushupWide",
        "QuadThoraticRotation",
        "QuadThoraticRotationLeft",
        "QuadThoraticRotationRight",
        "QuickFeet",
        "ReverseSitToTableTop",
        "ReverseTableTopHold",
        "RhomboidStretch",
        "SeatedBowArrowThoracicMobilityLeft",
        "SeatedBowArrowThoracicMobilityRight",
        "SeatedHipRotationsLeft",
        "SeatedHipRotationsRight",
        "SeatedThoracicSideBendingLeft",
        "SeatedThoracicSideBendingRight",
        "ShoulderCircles",
        "ShouldersPress",
        "SideStepJacks",
        "SingleHandOverheadHealDigs",
        "SingleLegHamstringStretchLeft",
        "SingleLegHamstringStretchRight",
        "SingleLegStanceLeft",
        "SingleLegStanceRight",
        "SitToStand",
        "SitupPenguin",
        "SitupRussianTwist",
        "SitupRussianTwistStatic",
        "SkaterHops",
        "SkiJumps",
        "Skydivers",
        "SkydiversHold",
        "Squat",
        "SquatAndKick",
        "SquatAndRotationJab",
        "SquatAndStep",
        "SquatNarrow",
        "SquatPulsing",
        "SquatRegular",
        "SquatRegularOverhead",
        "SquatRegularOverheadStatic",
        "SquatRegularStatic",
        "SquatSumo",
        "SquatSumoStatic",
        "StandingAlternateToeTouch",
        "StandingBicycleCrunches",
        "StandingBowArrowThoracicMobilityLeft",
        "StandingBowArrowThoracicMobilityRight",
        "StandingForwardFold",
        "StandingHamstringMobility",
        "StandingKneeRaiseLeft",
        "StandingKneeRaiseRight",
        "StandingObliqueCrunches",
        "StandingSideBendLeft",
        "StandingSideBendRight",
        "StandingStepReverseAirFly",
        "StandingThoracicSideBendingLeft",
        "StandingThoracicSideBendingRight",
        "ToesRaises",
        "TuckHold",
        "WideInnerThighStretch"
    ]

    private static let guidanceStarExcludedDetectors: Set<String> = [
        "GroinAndAdductor",
        "HappyBaby",
        "SingleLegStance",
        "SingleLegStanceLeft",
        "SingleLegStanceRight"
    ]

    static func allSupportedEntries() -> [DemoExerciseCatalogEntry] {
        loadSupportedDetectors()
            .map(buildEntry(detector:))
            .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
    }

    static func filteredEntries(_ filter: DemoExerciseFilter) -> [DemoExerciseCatalogEntry] {
        allSupportedEntries().filter { filter.contains($0.kind) }
    }

    static func entry(for detector: String) -> DemoExerciseCatalogEntry {
        buildEntry(detector: detector)
    }

    static func displayName(for detector: String) -> String {
        detector
            .replacingOccurrences(of: "QL", with: "Q L")
            .replacingOccurrences(of: "IT", with: "I T")
            .replacingOccurrences(of: "([a-z0-9])([A-Z])", with: "$1 $2", options: .regularExpression)
    }

    static func guidanceEntries() -> [DemoGuidanceExercise] {
        loadSupportedDetectors()
            .filter { GuidanceModePolicy.exerciseUsesDefaultGuidanceOrchestration(detector: $0) }
            .map { detector in
                let stepCount = GuidanceModePolicy.guidanceRanksToAnnounce(
                    from: 0,
                    through: 4,
                    detector: detector
                ).count
                return DemoGuidanceExercise(
                    detector: detector,
                    recommended: stepCount > 3 && !guidanceStarExcludedDetectors.contains(detector)
                )
            }
            .sorted {
                if $0.recommended != $1.recommended {
                    return $0.recommended && !$1.recommended
                }
                return $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
            }
    }

    private static func loadSupportedDetectors() -> [String] {
        let supported = SMKitUIModel.getSupportedMovements() ?? []
        return Array(Set(supported))
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .filter { $0.caseInsensitiveCompare("Rowing") != .orderedSame }
            .filter { feedbackCatalogDetectors.contains($0) }
    }

    private static func buildEntry(detector: String) -> DemoExerciseCatalogEntry {
        let kind = exerciseKind(for: detector)
        let targetRom = iosRomTargets[detector]
        let modes: [DemoAssessmentScoringMode]

        if kind.supportsRepScoring {
            modes = [.reps]
        } else if targetRom != nil {
            modes = [.rom, .time]
        } else {
            modes = [.time]
        }

        return DemoExerciseCatalogEntry(
            detector: detector,
            kind: kind,
            assessmentModes: modes,
            defaultDuration: kind.defaultDuration,
            defaultTargetReps: defaultTargetReps,
            defaultTargetTime: defaultTargetTime,
            targetRom: targetRom
        )
    }

    private static func exerciseKind(for detector: String) -> DemoExerciseKind {
        do {
            switch try SMKitUIModel.getExerciseType(type: detector) {
            case .Dynamic:
                return .dynamic
            case .Static:
                return .static
            case .Mobility:
                return .mobility
            case .BodyAssessment:
                return .bodyAssessment
            default:
                return .other
            }
        } catch {
            if detector.localizedCaseInsensitiveContains("Static") ||
                detector.localizedCaseInsensitiveContains("Hold") ||
                detector.localizedCaseInsensitiveContains("Stretch") {
                return .static
            }
            return .other
        }
    }

    private static let iosRomTargets: [String: String] = [
        "AnkleMobilityLeft": "AnklesMobilityBendLeg",
        "AnkleMobilityRight": "AnklesMobilityBendLeg",
        "GlutesBridgeHold": "GlutesBridgeHipExtension",
        "HipExternalRotationLeft": "HipExternalRotationArmsToTheSide",
        "HipExternalRotationRight": "HipExternalRotationArmsToTheSide",
        "HipFlexionLeft": "HipFlexionRaiseLeg",
        "HipFlexionRight": "HipFlexionRaiseLeg",
        "HipInternalRotationLeft": "HipInternalRotationRotationScore",
        "HipInternalRotationRight": "HipInternalRotationRotationScore",
        "HollowHold": "HollowHoldLegsLow",
        "InnerThighMobility": "InnerThighMobilityKneeAngle",
        "JeffersonCurl": "JeffersonCurlHandsReach",
        "LungeSideStaticLeft": "LungeSideBendLeg",
        "LungeSideStaticRight": "LungeSideBendLeg",
        "OverheadMobility": "OverheadMobilityRaiseHands",
        "PlankSideHighStatic": "PlankSideSag",
        "PlankSideHighStaticLeft": "PlankSideSag",
        "PlankSideHighStaticRight": "PlankSideSag",
        "PlankSideLowStatic": "PlankSideSag",
        "PlankSideLowStaticLeft": "PlankSideSag",
        "PlankSideLowStaticRight": "PlankSideSag",
        "ReverseTableTopHold": "ReverseSitToTableTopHipsRaise",
        "RhomboidStretch": "RhomboidStretchUpperBodyNotBent",
        "SeatedBowArrowThoracicMobilityLeft": "SeatedThoracicMobilityRotation",
        "SeatedBowArrowThoracicMobilityRight": "SeatedThoracicMobilityRotation",
        "SeatedThoracicSideBendingLeft": "SeatedThoracicSideBendingLateralFlex",
        "SeatedThoracicSideBendingRight": "SeatedThoracicSideBendingLateralFlex",
        "StandingKneeRaiseLeft": "StandingKneeRaiseElevation",
        "StandingKneeRaiseRight": "StandingKneeRaiseElevation",
        "StandingSideBendLeft": "StandingSideBendLateralTorsoFlex",
        "StandingSideBendRight": "StandingSideBendLateralTorsoFlex",
        "TuckHold": "TuckHoldRaise"
    ]
}

struct DemoGuidanceExercise: Equatable {
    let detector: String
    let recommended: Bool

    var displayName: String {
        ExerciseCatalog.displayName(for: detector)
    }
}

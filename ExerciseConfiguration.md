# Exercise Configuration

The SDK allows you to customize exercise feedback parameters by modifying the default configuration values. This enables you to adjust the sensitivity and thresholds for exercise feedback to match your specific requirements.

## Overview

Exercise configurations are passed as a `modifications` parameter when starting a workout or assessment. The structure follows this format:

```swift
[exerciseName: [feedbackName: [parameterName: value]]]
```

All parameter threshold values are normalized to the range `[0.0, 1.0]`.

## Usage Example

```swift
// Example: Customize exercise configuration
// This example modifies the HighKnees exercise to change the HighKneesRaise feedback threshold
// The structure is: [exerciseName: [feedbackName: [parameterName: value]]]
let modifications: [String: Any] = [
    "HighKnees": [
        "HighKneesRaise": [
            "low": 0.3,  // Changed from default 0.25
            "high": 0.8   // Changed from default 0.75
        ]
    ]
]

// For workouts
try SMKitUIModel.startWorkout(viewController: self, workout: workout, delegate: self, modifications: modifications)

// For assessments
try SMKitUIModel.startCustomAssessment(viewController: self, assessment: assessment, delegate: self, onFailure:  { error in
                self.showAlert(title: error.localizedDescription)
            }, modifications: modifications.isEmpty ? nil : modifications)
```

## Default Exercise Configurations

Below are the default configuration values for all supported exercises. These values serve as the baseline template that can be overridden by your modifications.

### Parameter Types

- **Threshold Parameters**: `low`, `high` - Define the acceptable range for feedback detection
- **Soft Thresholds**: `high_soft`, `high_start` - Additional thresholds for some feedbacks
- **Range of Motion**: `start`, `end` - Define the ROM range

### Exercise Configurations

```json
{
    "AlternateWindmillToeTouch": {
        "WindmillReach": { "low": 0.25, "high": 0.75 },
        "WindmillArmAlignment": { "low": 0.25, "high": 0.75 },
        "WindmillLegsStraight": { "low": 0.25, "high": 0.75 }
    },
    "AnkleMobilityLeft": {
        "heelOnGround": { "low": 0.25, "high": 0.75 },
        "legBent": { "low": 0.25, "high": 0.75 },
        "AnklesMobilityRom": { "start": 0.27778, "end": 0.66667 }
    },
    "AnkleMobilityRight": {
        "heelOnGround": { "low": 0.25, "high": 0.75 },
        "legBent": { "low": 0.25, "high": 0.75 },
        "AnklesMobilityRom": { "start": 0.27778, "end": 0.66667 }
    },
    "Burpees": {
        "BurpeesPushupDepth": { "low": 0.25, "high": 0.75 },
        "BurpeesJumpHeight": { "low": 0.25, "high": 0.75 },
        "BurpeesTempo": { "low": 0.25, "high": 0.75 },
        "BurpeesHandsUp": { "low": 0.25, "high": 1.0 }
    },
    "Crunches": {
        "CrunchesShallowDepth": { "low": 0.25, "high": 0.75 }
    },
    "Froggers": {
        "FroggersWristsRange": { "low": 0.25, "high": 0.75 },
        "FroggersKneesValgus": { "low": 0.25, "high": 1.0 },
        "FroggersAnkleSymmetry": { "low": 0.25, "high": 0.75 },
        "FroggersWristSymmetry": { "low": 0.25, "high": 0.75 }
    },
    "GlutesBridge": {
        "GlutesBrHipExtensionFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "GlutesBrHipExtensionElevated": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "GlutesBrFeetFloor": { "low": 0.25, "high": 0.75 },
        "GlutesBrFeetElevated": { "low": 0.25, "high": 0.75 }
    },
    "HamstringMobility": {
        "Depth": { "low": 0.25, "high": 0.75 },
        "HamstringMobilitySideView": { "low": 0.25, "high": 0.75 },
        "HamstringMobilityLegsStraight": { "low": 0.25, "high": 0.75 },
        "HamstringMobilityRom": { "start": 0.5, "end": 1.0 }
    },
    "HighKnees": {
        "HighKneesRaise": { "low": 0.25, "high": 0.75 }
    },
    "HipExternalRotationRight": {
        "ankleOnKnee": { "low": 0.25, "high": 0.75 },
        "handAside": { "low": 0.5, "high": 1.0 },
        "HipExternalRotationGlutesMobilityRom": { "start": 0.38889, "end": 1.0 }
    },
    "HipExternalRotationLeft": {
        "ankleOnKnee": { "low": 0.25, "high": 0.75 },
        "handAside": { "low": 0.5, "high": 1.0 },
        "HipExternalRotationGlutesMobilityRom": { "start": 0.38889, "end": 1.0 }
    },
    "HipFlexionRight": {
        "legStraight": { "low": 0.85, "high": 1.0 },
        "torsoInline": { "low": 0.25, "high": 0.75 },
        "HipFlexionMobilityRom": { "start": 0.44444, "end": 0.88889 }
    },
    "HipFlexionLeft": {
        "legStraight": { "low": 0.85, "high": 1.0 },
        "torsoInline": { "low": 0.25, "high": 0.75 },
        "HipFlexionMobilityRom": { "start": 0.44444, "end": 0.88889 }
    },
    "HipInternalRotationRight": {
        "handAside": { "low": 0.3, "high": 1.0 },
        "hipRotation": { "low": 0.25, "high": 0.75 },
        "kneesAttached": { "low": 0.5, "high": 1.0 },
        "HipInternalRotationMobilityRom": { "start": 0.28444, "end": 0.71111 }
    },
    "HipInternalRotationLeft": {
        "handAside": { "low": 0.3, "high": 1.0 },
        "hipRotation": { "low": 0.3, "high": 0.75 },
        "kneesAttached": { "low": 0.5, "high": 1.0 },
        "HipInternalRotationMobilityRom": { "start": 0.28444, "end": 0.71111 }
    },
    "InnerThighMobility": {
        "handsAboveHip": { "low": 0.5, "high": 1.0 },
        "InnerThighMobilityRom": { "start": 0.69444, "end": 1.0 }
    },
    "JumpingJacks": {
        "JJArmExtension": { "low": 0.25, "high": 0.75 },
        "JJLegSpread": { "low": 0.25, "high": 0.75 }
    },
    "LateralRaises": {
        "LateralRaisesHeight": { "low": 0.25, "high": 0.75 },
        "LateralRaisesArmStraightness": { "low": 0.25, "high": 0.75 }
    },
    "LungeFront": {
        "SideViewFrontKneeBendAngle": { "low": 0.25, "high": 0.75 },
        "SideViewFrontLungeTorsoUpright": { "low": 0.25, "high": 0.75 },
        "FrontViewFrontLungeKneeBendRatio": { "low": 0.25, "high": 0.75 }
    },
    "LungeFrontLeft": {
        "SideViewFrontKneeBendAngle": { "low": 0.25, "high": 0.75 },
        "SideViewFrontLungeTorsoUpright": { "low": 0.25, "high": 0.75 },
        "FrontViewFrontLungeKneeBendRatio": { "low": 0.25, "high": 0.75 }
    },
    "LungeFrontRight": {
        "SideViewFrontKneeBendAngle": { "low": 0.25, "high": 0.75 },
        "SideViewFrontLungeTorsoUpright": { "low": 0.25, "high": 0.75 },
        "FrontViewFrontLungeKneeBendRatio": { "low": 0.25, "high": 0.75 }
    },
    "LungeRegularStaticLeft": {
        "DepthFloor": { "low": 0.25, "high": 0.75 },
        "KneesCollapsingFloor": { "low": 0.25, "high": 0.75 }
    },
    "LungeRegularStaticRight": {
        "DepthFloor": { "low": 0.25, "high": 0.75 },
        "KneesCollapsingFloor": { "low": 0.25, "high": 0.75 }
    },
    "LungeSideStaticLeft": {
        "SideLungeBendLeg": { "low": 0.5, "high": 1.0 },
        "SideLungeLegStraight": { "low": 0.25, "high": 0.75 },
        "SideLungeAnkleWidth": { "low": 0.25, "high": 0.75 },
        "SideLungeForwardLean": { "low": 0.1026, "high": 1.0 }
    },
    "LungeSideStaticRight": {
        "SideLungeBendLeg": { "low": 0.5, "high": 1.0 },
        "SideLungeLegStraight": { "low": 0.25, "high": 0.75 },
        "SideLungeAnkleWidth": { "low": 0.25, "high": 0.75 },
        "SideLungeForwardLean": { "low": 0.1026, "high": 1.0 }
    },
    "OverheadMobility": {
        "handRaised": { "low": 0.25, "high": 0.75 },
        "handStraight": { "low": 0.25, "high": 0.75 },
        "ribsStraight": { "low": 0.25, "high": 0.75 },
        "torsoInline": { "low": 0.25, "high": 0.75 },
        "OverheadMobilityRom": { "start": 0.42857, "end": 0.90476 }
    },
    "PlankHighKneeToElbow": {
        "KneeToElbowDist": { "low": 0.25, "high": 0.75 }
    },
    "PlankHighShoulderTaps": {
        "PalmReachShoulderElevated": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "PalmReachShoulderFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "HipsRotatingElevated": { "low": 0.25, "high": 0.75 },
        "HipsRotatingFloor": { "low": 0.25, "high": 0.75 },
        "KneesFloorElevated": { "low": 0.25, "high": 0.75 },
        "KneesFloorFloor": { "low": 0.25, "high": 1.0 },
        "PlankHipsSagOrPikeElevated": { "low": 0.25, "high": 0.75 },
        "PlankHipsSagOrPikeFloor": { "low": 0.125, "high": 0.9 }
    },
    "PlankHighStatic": {
        "DepthFloor": { "low": 0.25, "high": 0.75 },
        "PlankHipsSagOrPikeFloor": { "low": 0.25, "high": 0.75 },
        "PlankKneesOnFloor": { "low": 0.25, "high": 1.0 }
    },
    "PlankSideLowStatic": {
        "SidePlankBodyAlignment": { "low": 0.25, "high": 0.75 },
        "SidePlankShoulderStacking": { "low": 0.25, "high": 0.75 },
        "SidePlankTorsoRotation": { "low": 0.25, "high": 0.75 },
        "SidePlankSag": { "low": 0.25, "high": 0.75 }
    },
    "PushupRegular": {
        "PushupDepthFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "PushupHipsSagOrPikeFloor": { "low": 0.125, "high": 0.9 },
        "PushupKneesLowFloor": { "low": 0.25, "high": 0.75 }
    },
    "PushupWide": {
        "PushupDepthFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "PushupKneesLowFloor": { "low": 0.2, "high": 0.75 },
        "PushupHandsDistFloor": { "low": 0.3, "high": 0.6875 },
        "PushupHipsSagOrPikeFloor": { "low": 0.125, "high": 0.9 }
    },
    "PushupNarrow": {
        "PushupDepthFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "PushupKneesLowFloor": { "low": 0.2, "high": 0.75 },
        "PushupHandsDistFloor": { "low": 0.275, "high": 0.825 },
        "PushupHipsSagOrPikeFloor": { "low": 0.125, "high": 0.9 }
    },
    "PushupKneesRegular": {
        "PushupDepthFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "PushupHipsSagOrPikeFloor": { "low": 0.25, "high": 0.75 }
    },
    "PushupKneesWide": {
        "PushupDepthFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "PushupHandsDistFloor": { "low": 0.3, "high": 0.6875 }
    },
    "PushupKneesNarrow": {
        "PushupDepthFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "PushupHandsDistFloor": { "low": 0.275, "high": 0.825 }
    },
    "QuadThoraticRotation": {
        "QuadRotationTotalROM": { "low": 0.25, "high": 0.75 },
        "QuadRotationHipStability": { "low": 0.0, "high": 0.9 },
        "QuadRotationTempo": { "low": 0.25, "high": 0.75 }
    },
    "ReverseSitToTableTop": {
        "ReverseSitToTableTopShoulderAlignment": { "low": 0.25, "high": 0.75 },
        "ReverseSitToTableTopRom": { "start": 0.4, "end": 0.75 }
    },
    "ShouldersPress": {
        "ShouldersPressHeight": { "low": 0.25, "high": 0.75 },
        "ShouldersPressHandsStraight": { "low": 0.25, "high": 0.75 },
        "ShouldersPressSymmetry": { "low": 0.25, "high": 0.75 }
    },
    "LungeSide": {
        "SideLungeBendLeg": { "low": 0.5, "high": 0.75 },
        "SideLungeLegStraight": { "low": 0.25, "high": 0.75 },
        "SideLungeAnkleWidth": { "low": 0.25, "high": 0.75 },
        "SideLungeForwardLean": { "low": 0.1026, "high": 1.0 }
    },
    "LungeSideLeft": {
        "SideLungeBendLeg": { "low": 0.5, "high": 0.75 },
        "SideLungeLegStraight": { "low": 0.25, "high": 0.75 },
        "SideLungeAnkleWidth": { "low": 0.25, "high": 0.75 },
        "SideLungeForwardLean": { "low": 0.1026, "high": 1.0 }
    },
    "LungeSideRight": {
        "SideLungeBendLeg": { "low": 0.5, "high": 0.75 },
        "SideLungeLegStraight": { "low": 0.25, "high": 0.75 },
        "SideLungeAnkleWidth": { "low": 0.25, "high": 0.75 },
        "SideLungeForwardLean": { "low": 0.1026, "high": 1.0 }
    },
    "SkaterHops": {
        "SkaterHopsAirLegRange": { "low": 0.25, "high": 0.75 },
        "SkaterHopsActiveLegBending": { "low": 0.25, "high": 0.75 }
    },
    "SkiJumps": {
        "SkiJumpsLateralDist": { "low": 0.25, "high": 1.0 },
        "SkiJumpsLanding": { "low": 0.25, "high": 0.75 }
    },
    "SquatRegular": {
        "DepthFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "KneesCollapsingFloor": { "low": 0.25, "high": 0.75 },
        "SquatForwardLeanFloor": { "low": 0.1026, "high": 1.0 }
    },
    "SquatRegularStatic": {
        "DepthFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "KneesCollapsingFloor": { "low": 0.25, "high": 0.75 },
        "SquatForwardLeanFloor": { "low": 0.1795, "high": 1.0 }
    },
    "SquatNarrow": {
        "DepthFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "KneesCollapsingFloorNarrow": { "low": 0.25, "high": 0.75 },
        "AnkleWidthFloor": { "low": 0.0, "high": 0.5 },
        "SquatForwardLeanFloor": { "low": 0.1026, "high": 1.0 }
    },
    "SquatRegularOverhead": {
        "DepthFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "KneesCollapsingFloor": { "low": 0.25, "high": 0.75 },
        "OverheadHandsFloor": { "low": 0.25, "high": 0.75 },
        "SquatForwardLeanFloor": { "low": 0.051282, "high": 0.75 }
    },
    "SquatRegularOverheadStatic": {
        "DepthFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "KneesCollapsingFloor": { "low": 0.25, "high": 0.75 },
        "OverheadHandsFloor": { "low": 0.25, "high": 0.75 },
        "SquatForwardLeanFloor": { "low": 0.2308, "high": 0.75 }
    },
    "SquatAndStep": {
        "DepthFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "KneesCollapsingFloor": { "low": 0.25, "high": 0.75 },
        "AnkleStanceFloor": { "low": 0.25, "high": 0.75 }
    },
    "SquatSumo": {
        "DepthFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "KneesCollapsingFloorSumo": { "low": 0.25, "high": 0.75 },
        "AnkleWidthFloor": { "low": 1.0, "high": 1.0 },
        "SquatForwardLeanFloor": { "low": 0.1026, "high": 0.75 }
    },
    "SquatSumoStatic": {
        "DepthFloor": { "low": 0.25, "high": 0.75, "high_soft": 0.8, "high_start": 0.9 },
        "KneesCollapsingFloorSumo": { "low": 0.25, "high": 0.75 },
        "AnkleWidthFloor": { "low": 1.0, "high": 1.0 },
        "SquatForwardLeanFloor": { "low": 0.1795, "high": 0.75 }
    },
    "StandingAlternateToeTouch": {
        "StandingAlternateToeTouchReach": { "low": -0.25, "high": 0.75 },
        "StandingAlternateToeTouchLegsStraight": { "low": 0.25, "high": 0.75 },
        "StandingAlternateToeTouchRom": { "start": 0.5, "end": 1.0 }
    },
    "StandingBicycleCrunches": {
        "StandingBicycleCrunchesDist": { "low": 0.25, "high": 0.75 },
        "StandingBicycleCrunchesTorsoRotation": { "low": 0.25, "high": 0.75 }
    },
    "StandingKneeRaiseLeft": {
        "StandingKneeRaiseElevation": { "low": 0.25, "high": 1.0 },
        "StandingKneeRaiseUpperBodyStability": { "low": 0.0, "high": 0.333 }
    },
    "StandingKneeRaiseRight": {
        "StandingKneeRaiseElevation": { "low": 0.25, "high": 1.0 },
        "StandingKneeRaiseUpperBodyStability": { "low": 0.0, "high": 0.333 }
    },
    "StandingObliqueCrunches": {
        "StandingObliqueCrunchesKneeLiftHeight": { "low": 0.25, "high": 0.75 },
        "StandingObliqueCrunchesTorsoRotation": { "low": 0.25, "high": 0.75 }
    },
    "StandingSideBendLeft": {
        "SideBendLateralTorsoFlex": { "low": 0.464, "high": 1.0 },
        "SideBendHandsAboveHead": { "low": 0.25, "high": 0.75 },
        "SideBendTorsoRotation": { "low": 0.25, "high": 0.75 },
        "SideBendFeetOnFloor": { "low": 0.25, "high": 0.75 },
        "SideBendArmsStraight": { "low": 0.25, "high": 1.0 },
        "StandingSideBendRom": { "start": 0.231, "end": 1.0 }
    },
    "StandingSideBendRight": {
        "SideBendLateralTorsoFlex": { "low": 0.464, "high": 1.0 },
        "SideBendHandsAboveHead": { "low": 0.25, "high": 0.75 },
        "SideBendTorsoRotation": { "low": 0.25, "high": 0.75 },
        "SideBendFeetOnFloor": { "low": 0.25, "high": 0.75 },
        "SideBendArmsStraight": { "low": 0.25, "high": 1.0 },
        "StandingSideBendRom": { "start": 0.231, "end": 1.0 }
    },
    "TuckHold": {
        "TuckHoldAngle": { "low": 0.25, "high": 1.0 },
        "TuckHoldBackStraightness": { "low": 0.25, "high": 0.75 },
        "TuckHoldHeelsHeight": { "low": 0.25, "high": 0.75 },
        "TuckHoldKneeBend": { "low": 0.25, "high": 0.75 }
    },
    "JeffersonCurl": {
        "JeffersonCurlRom": { "start": 0.35, "end": 1.0 }
    }
}
```

## How to Modify Configurations

1. **Identify the exercise name** - Use the exact exercise detector name (e.g., `"HighKnees"`, `"SquatRegularStatic"`)

2. **Identify the feedback name** - Find the specific feedback you want to modify (e.g., `"HighKneesRaise"`, `"DepthFloor"`)

3. **Identify the parameter** - Determine which parameter to adjust:
   - `low`: Lower threshold for feedback detection
   - `high`: Upper threshold for feedback detection
   - `high_soft`: Soft upper threshold (if applicable)
   - `high_start`: Start threshold (if applicable)
   - `start`/`end`: Range of motion boundaries (for mobility exercises)

4. **Set the new value** - Provide a value between 0.0 and 1.0

5. **Pass to SDK** - Include the modifications dictionary when calling `startWorkout` or `startCustomAssessment`

## Example: Modifying Multiple Exercises

```swift
let modifications: [String: Any] = [
    "HighKnees": [
        "HighKneesRaise": [
            "low": 0.3,
            "high": 0.8
        ]
    ],
    "SquatRegularStatic": [
        "DepthFloor": [
            "low": 0.3,
            "high": 0.8,
            "high_soft": 0.85,
            "high_start": 0.95
        ]
    ]
]
```

## Notes

- Only include parameters you want to modify. Unspecified parameters will use their default values.
- Parameter values are normalized to the range `[0.0, 1.0]`.
- Modifications apply only to the current workout/assessment session.


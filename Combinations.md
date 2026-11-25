# Exercise Combinations

A combination joins two movements into one exercise. The user performs the first movement, then the second, and each completed pair counts as one rep. SMKitUI selects the instruction videos and audio cues for both movements.

## Create a combination

Use `SMExercise.combination(number:...)` with the recipe number from the [catalog](#catalog):

```swift
// Combo01: squat + standing bicycle crunch
let combo = try SMExercise.combination(
    number: 1,
    name: "Squat + Bicycle Crunch",
    totalSeconds: 60,
    targetReps: 8,      // Optional. Ends the exercise after 8 completed combinations.
    firstReps: 1,       // Squats per combination
    secondReps: 2,      // Bicycle crunches per combination (one per side)
    fixedSide: nil      // Optional .left or .right lead side
)

let workout = SMWorkout(
    id: "",
    name: "Combination Workout",
    workoutIntro: nil,
    soundtrack: nil,
    exercises: [combo],
    workoutClosure: nil
)
try SMKitUIModel.startWorkout(viewController: self, workout: workout, delegate: self)
```

The factory throws `SMWorkoutError.InvaildSMExercise` when the number is not in the catalog or `totalSeconds` is not positive. The exercise shows the timer and rep counter.

You can also build it yourself with the `ComboXX` detector and `SMCombinationOptions`:

```swift
let combo = SMExercise(
    name: "Squat + Bicycle Crunch",
    exerciseIntro: nil,
    totalSeconds: 60,
    videoInstruction: nil,
    uiElements: [.timer, .repsCounter],
    detector: "Combo01",
    exerciseClosure: nil,
    playSoundOnEachRep: true
)
combo.combinationOptions = try SMCombinationOptions(firstReps: 1, secondReps: 2)
combo.targetReps = 8
```

### From JSON

A combination is one item in the workout's `activities` array. Don't split the two movements into separate activities.

```json
{
  "prettyName": "Squat + standing bicycle crunch",
  "detector": "Combo01",
  "totalSeconds": 60,
  "targetReps": 8,
  "uiElements": ["timer", "repsCounter"],
  "playSoundOnEachRep": true,
  "combinationOptions": {
    "firstReps": 1,
    "secondReps": 2
  }
}
```

With these settings one counted combination is one squat, then one standing bicycle crunch on each side. Eight combinations means eight squats and sixteen bicycle crunches.

Pass the complete workout to `SMKitUIModel.predownloadWorkoutAssets(workout:...)` or `startWorkout` so the SDK can select the assets for both movements.

## Rep settings

| Option | Description |
|--------|-------------|
| `firstReps`, `secondReps` | Reps of each movement per combination, from 1 up to the maximum in the catalog. Values above the maximum are clamped; values below 1 throw. When omitted, the recipe default is used (not always 1 + 1). |
| `fixedSide` | `.left` or `.right` to choose the lead side for the whole exercise. When omitted, the lead starts on the right and switches after each completed combination. |
| `targetReps` (on `SMExercise`) | Counts completed combinations, not individual movements. |
| `playSoundOnEachRep` (on `SMExercise`) | Plays the rep sound for each completed combination. |

Each accepted movement counts as one rep toward `firstReps` or `secondReps`. For Combo01, `firstReps: 2` and `secondReps: 4` means two squats and four bicycle crunches (two per side).

### Movement types

- **Bilateral**: both sides together. Side selection has no effect.
- **Paired**: 1 rep on the lead side, or 2 or more reps alternating sides from the lead.
- **Alternating**: 1 rep on the lead side, or 2 or more reps alternating sides. Either side may start a multi-rep block when `fixedSide` is omitted.

For sided movements, 3 reps alternate A–B–A and 4 reps alternate A–B–A–B. In **Combo12** and **Combo56**, the second movement uses the opposite lead. Bird dog names the side by the reaching arm.

## Catalog <a name="catalog"></a>

| ID | Combination | Movement detectors | Default first + second | First movement | Second movement | Max first + second |
|---|---|---|---|---|---|---|
| Combo01 | Squat + standing bicycle crunch | SquatRegular + StandingBicycleCrunches | 1 + 2 | Bilateral | Alternating | 4 + 4 |
| Combo02 | Squat + standing oblique crunch | SquatRegular + StandingObliqueCrunches | 1 + 2 | Bilateral | Alternating | 4 + 4 |
| Combo03 | Squat + calf raise | SquatRegular + CalfRaises | 1 + 1 | Bilateral | Bilateral | 4 + 4 |
| Combo04 | Squat + standing hip abduction | SquatRegular + StandingHipAbductions | 1 + 1 | Bilateral | Paired | 4 + 4 |
| Combo05 | Squat + squat pulses | SquatRegular + SquatPulsing | 1 + 2 | Bilateral | Bilateral | 4 + 4 |
| Combo06 | Narrow squat + sumo squat | SquatNarrow + SquatSumo | 1 + 1 | Bilateral | Bilateral | 4 + 4 |
| Combo07 | Squat + side lunge | SquatRegular + LungeSide | 1 + 1 | Bilateral | Paired | 4 + 4 |
| Combo08 | Forward lunge + standing knee drive | LungeFront + StandingKneeDrives | 1 + 1 | Paired | Paired | 4 + 4 |
| Combo09 | Forward lunge + standing hamstring curl | LungeFront + StandingHamstringCurls | 1 + 1 | Paired | Paired | 4 + 4 |
| Combo10 | Side lunge + standing hip abduction | LungeSide + StandingHipAbductions | 1 + 1 | Paired | Paired | 4 + 4 |
| Combo11 | Side lunge + standing bicycle crunch | LungeSide + StandingBicycleCrunches | 1 + 2 | Paired | Alternating | 4 + 4 |
| Combo12 | Single-leg deadlift + standing knee drive | SingleLegDeadlift + StandingKneeDrives | 1 + 1 | Paired | Paired | 4 + 4 |
| Combo13 | Standing hamstring curl + standing knee drive | StandingHamstringCurls + StandingKneeDrives | 1 + 1 | Paired | Paired | 4 + 4 |
| Combo14 | Sumo squat + alternating windmill toe touch | SquatSumo + AlternateWindmillToeTouch | 1 + 2 | Bilateral | Alternating | 4 + 4 |
| Combo15 | Squat + high knees | SquatRegular + HighKnees | 1 + 2 | Bilateral | Alternating | 4 + 8 |
| Combo16 | Squat + jumping jacks | SquatRegular + JumpingJacks | 1 + 2 | Bilateral | Bilateral | 4 + 8 |
| Combo17 | Quick feet + squat | QuickFeet + SquatRegular | 2 + 1 | Alternating | Bilateral | 8 + 4 |
| Combo18 | Skater hops + squat | SkaterHops + SquatRegular | 2 + 1 | Alternating | Bilateral | 8 + 4 |
| Combo19 | Lateral shuffle + squat | LateralShuffle + SquatRegular | 1 + 1 | Bilateral | Bilateral | 8 + 4 |
| Combo20 | Squat jump + high knees | SquatJump + HighKnees | 1 + 2 | Bilateral | Alternating | 8 + 8 |
| Combo21 | Skater hops + squat jump | SkaterHops + SquatJump | 2 + 1 | Alternating | Bilateral | 8 + 8 |
| Combo22 | Pogo jumps + squat jump | PogoJumps + SquatJump | 2 + 1 | Bilateral | Bilateral | 8 + 8 |
| Combo23 | Jumping jacks + high knees | JumpingJacks + HighKnees | 2 + 2 | Bilateral | Alternating | 8 + 8 |
| Combo24 | Jumping jacks + butt kicks | JumpingJacks + ButtKicks | 2 + 2 | Bilateral | Alternating | 8 + 8 |
| Combo25 | High knees + butt kicks | HighKnees + ButtKicks | 2 + 2 | Alternating | Alternating | 8 + 8 |
| Combo26 | Jumping jacks + standing bicycle crunch | JumpingJacks + StandingBicycleCrunches | 1 + 2 | Bilateral | Alternating | 8 + 4 |
| Combo27 | Jumping jacks + squat jack | JumpingJacks + SquatJack | 2 + 1 | Bilateral | Bilateral | 8 + 8 |
| Combo28 | Jumping jacks + cross jacks | JumpingJacks + CrossJacks | 2 + 2 | Bilateral | Alternating | 8 + 8 |
| Combo29 | Seal jacks + high knees | SealJacks + HighKnees | 2 + 2 | Bilateral | Alternating | 8 + 8 |
| Combo30 | Air jump rope + high knees | AirJumpRope + HighKnees | 2 + 2 | Bilateral | Alternating | 8 + 8 |
| Combo31 | Quick feet + high knees | QuickFeet + HighKnees | 2 + 2 | Alternating | Alternating | 8 + 8 |
| Combo32 | Quick feet + sprawl | QuickFeet + Sprawl | 2 + 1 | Alternating | Bilateral | 8 + 8 |
| Combo33 | Lateral shuffle + sprawl | LateralShuffle + Sprawl | 1 + 1 | Bilateral | Bilateral | 8 + 8 |
| Combo34 | Skater hops + high knees | SkaterHops + HighKnees | 2 + 2 | Alternating | Alternating | 8 + 8 |
| Combo35 | Side-step jacks + standing bicycle crunch | SideStepJacks + StandingBicycleCrunches | 2 + 2 | Alternating | Alternating | 8 + 4 |
| Combo36 | Lateral step touch + standing oblique crunch | LateralStepTouch + StandingObliqueCrunches | 2 + 2 | Alternating | Alternating | 8 + 4 |
| Combo37 | Push-up + plank shoulder taps | PushupRegular + PlankHighShoulderTaps | 1 + 2 | Bilateral | Alternating | 4 + 4 |
| Combo38 | Push-up + plank jacks | PushupRegular + PlankJacksHigh | 1 + 2 | Bilateral | Bilateral | 4 + 8 |
| Combo39 | Push-up + frogger | PushupRegular + Froggers | 1 + 1 | Bilateral | Bilateral | 4 + 4 |
| Combo40 | Push-up + down-and-up plank | PushupRegular + PlankComando | 1 + 1 | Bilateral | Alternating | 4 + 4 |
| Combo41 | Down-and-up plank + plank shoulder taps | PlankComando + PlankHighShoulderTaps | 1 + 2 | Bilateral | Alternating | 4 + 4 |
| Combo42 | Down-and-up plank + plank jacks | PlankComando + PlankJacksHigh | 1 + 2 | Bilateral | Bilateral | 4 + 8 |
| Combo43 | Down-and-up plank + forearm plank hip dips | PlankComando + PlankLowHipTwist | 1 + 2 | Bilateral | Alternating | 4 + 4 |
| Combo44 | Plank walkout + push-up | PlankWalkouts + PushupRegular | 1 + 1 | Bilateral | Bilateral | 4 + 4 |
| Combo45 | Plank walkout + plank shoulder taps | PlankWalkouts + PlankHighShoulderTaps | 1 + 2 | Bilateral | Alternating | 4 + 4 |
| Combo46 | Plank walkout + plank jacks | PlankWalkouts + PlankJacksHigh | 1 + 2 | Bilateral | Bilateral | 4 + 8 |
| Combo47 | Plank walkout + down-and-up plank | PlankWalkouts + PlankComando | 1 + 1 | Bilateral | Bilateral | 4 + 4 |
| Combo48 | Standing walkout + squat | FullPlankWalkouts + SquatRegular | 1 + 1 | Bilateral | Bilateral | 4 + 4 |
| Combo49 | Burpee + high knees | Burpees + HighKnees | 1 + 2 | Bilateral | Alternating | 4 + 8 |
| Combo50 | Burpee + jumping jacks | Burpees + JumpingJacks | 1 + 2 | Bilateral | Bilateral | 4 + 8 |
| Combo51 | Burpee + skater hops | Burpees + SkaterHops | 1 + 2 | Bilateral | Alternating | 4 + 8 |
| Combo52 | Crunch + reverse crunch | Crunches + ReverseCrunches | 1 + 1 | Bilateral | Bilateral | 4 + 4 |
| Combo53 | Reverse crunch + dead bug | ReverseCrunches + DeadBug | 1 + 2 | Bilateral | Alternating | 4 + 4 |
| Combo54 | Glute bridge + crunch | GlutesBridge + Crunches | 1 + 1 | Bilateral | Bilateral | 4 + 4 |
| Combo55 | Glute bridge + dead bug | GlutesBridge + DeadBug | 1 + 2 | Bilateral | Alternating | 4 + 4 |
| Combo56 | Bird dog + donkey kick | BirdDog + DonkeyKicks | 1 + 1 | Alternating | Paired | 4 + 4 |
| Combo57 | Bird dog + quadruped thoracic rotation | BirdDog + QuadThoraticRotation | 1 + 1 | Alternating | Paired | 4 + 4 |
| Combo58 | Reverse tabletop lift + reverse tabletop march | ReverseSitToTableTop + ReverseTableTopMarch | 1 + 2 | Bilateral | Paired | 4 + 4 |
| Combo59 | Lateral arm raise + front arm raise | LateralRaises + StandingArmFrontRaises | 1 + 1 | Bilateral | Paired | 4 + 4 |
| Combo60 | Standing W pull + standing Y raise | StandingWPulls + StandingYRaises | 1 + 1 | Bilateral | Bilateral | 4 + 4 |
| Combo61 | Standing bicycle crunch + oblique crunch | StandingBicycleCrunches + StandingObliqueCrunches | 1 + 1 | Alternating | Alternating | 4 + 4 |
| Combo62 | Shoulder taps + plank jacks | PlankHighShoulderTaps + PlankJacksHigh | 1 + 1 | Alternating | Bilateral | 4 + 8 |
| Combo63 | Shoulder taps + toe taps | PlankHighShoulderTaps + PlankHighToeTaps | 1 + 1 | Alternating | Alternating | 4 + 4 |
| Combo64 | Push-up + toe taps | PushupRegular + PlankHighToeTaps | 1 + 1 | Bilateral | Alternating | 4 + 4 |
| Combo65 | Plank jacks + toe taps | PlankJacksHigh + PlankHighToeTaps | 1 + 1 | Bilateral | Alternating | 8 + 4 |
| Combo66 | Donkey kick + thoracic rotation | DonkeyKicks + QuadThoraticRotation | 1 + 1 | Paired | Paired | 4 + 4 |
| Combo67 | Lateral raise + shoulder press | LateralRaises + ShouldersPress | 1 + 1 | Bilateral | Bilateral | 4 + 4 |
| Combo68 | Front raise + shoulder press | StandingArmFrontRaises + ShouldersPress | 1 + 1 | Paired | Bilateral | 4 + 4 |
| Combo69 | W-pull + lateral raise | StandingWPulls + LateralRaises | 1 + 1 | Bilateral | Bilateral | 4 + 4 |
| Combo70 | Sit-to-stand + calf raise | SitToStand + CalfRaises | 1 + 1 | Bilateral | Bilateral | 4 + 4 |

In Combo63–65, toe taps are high-plank toe taps. Combo57 and Combo66 use the quadruped thoracic rotation.

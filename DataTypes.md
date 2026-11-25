# Data

SMKitUI delivers results through `SMKitUIWorkoutDelegate`:

- `exerciseDidFinish(data: ExerciseData)` after each exercise.
- `didReceiveSummaryData(data: WorkoutSummaryData?)` when the session summary is available.

All result types are `Codable`. The tables list the Swift property name and the matching JSON key produced when the value is encoded.

## WorkoutSummaryData

| Swift property | JSON key | Type | Description |
|----------------|----------|------|-------------|
| `sessionId` | `session_id` | `String` | Session identifier. |
| `activityType` | `type` | `WorkoutType?` | `.customWorkout`, `.assessment`, `.customAssessment`, or `.workoutFromProgram`. |
| `exercises` | `exercises` | `[ExerciseData]` | Data for each exercise performed in the session. |
| `score` | `total_score` | `Int?` | Overall session score in the range [0-100]. |
| `scoreSegmented` | `total_score_segmented` | `Int?` | Segmented overall score in the range [0-100]. |
| `startTime` | `start_time` | `String` | UTC, `"YYYY-MM-dd HH:mm:ss.SSSZ"`. |
| `endTime` | `end_time` | `String` | UTC, `"YYYY-MM-dd HH:mm:ss.SSSZ"`. |
| `totalTime` | `total_time` | `Double` | Seconds from session start to session end. |
| `userData` | `user_data` | `UserData?` | User details. |
| `workoutDetails` | `workout_details` | `WorkoutConfig?` | The program configuration, for program workouts. |
| `modifications` | `modifications` | `[WorkoutModificationEvent]?` | In-session changes such as switched exercises or added rest. |
| `sessionLanguage` | `language` | `String` | Session language code (`en`, `he`, `zh`). |

## AssessmentData

| Swift property | JSON key | Type | Description |
|----------------|----------|------|-------------|
| `sessionID` | `session_id` | `String` | Session identifier. |
| `type` | `type` | `String` | Assessment type. |
| `assessmentID` | `assessment_id` | `String?` | Assessment identifier, when available. |
| `userData` | `user_data` | `UserData?` | User details. |
| `exercises` | `exercises` | `[ExerciseData]` | Data for each exercise. |
| `totalScore` | `total_score` | `Int` | Number in range [0-100]. |
| `totalScoreSegmented` | `total_score_segmented` | `Int?` | Number in range [0-100]. |
| `startTime` | `start_time` | `String` | UTC, `"YYYY-MM-dd HH:mm:ss.SSSZ"`. |
| `endTime` | `end_time` | `String` | UTC, `"YYYY-MM-dd HH:mm:ss.SSSZ"`. |
| `totalTime` | `total_time` | `Double` | Seconds from session start to session end. |
| `workoutDetails` | `workout_details` | `WorkoutConfig?` | Program configuration, when relevant. |
| `modifications` | `modifications` | `[WorkoutModificationEvent]?` | In-session changes. |
| `sessionLanguage` | `language` | `String` | Session language code. |

## ExerciseData

`ExerciseData` is the base class. Dynamic exercises are delivered as `ExerciseDynamicData` and static exercises as `ExerciseStaticData`; cast to read their extra fields.

| Swift property | JSON key | Type | Description |
|----------------|----------|------|-------------|
| `sessionId` | `session_id` | `String` | Session identifier. |
| `name` | — | `String` | Technical exercise name. |
| `prettyName` | `pretty_name` | `String` | Exercise display name. |
| `exerciseId` | `exercise_id` | `String?` | The detector name. |
| `activityType` | `activity_type` | `String?` | Session type. |
| `targetTime` | — | `Double?` | Target duration in seconds. |
| `startTime` | `start_time` | `String` | UTC, `"YYYY-MM-dd HH:mm:ss.SSSZ"`. |
| `endTime` | `end_time` | `String` | UTC, `"YYYY-MM-dd HH:mm:ss.SSSZ"`. |
| `totalTime` | `total_time` | `Double` | Exercise time in seconds. |
| `totalScore` | `total_score` | `Float?` | Number in range [0-100]. `scoreFactor × performance + (1 − scoreFactor) × technique`. |
| `totalScoreSegmented` | `total_score_segmented` | `Float?` | Number in range [0-100]. |
| `performanceScore` | `performance_score` | `Float?` | Number in range [0-100]. |
| `performanceScoreSegmented` | `performance_score_segmented` | `Float?` | Number in range [0-100]. |
| `techniqueScore` | `technique_score` | `Float?` | Number in range [0-100]. |
| `techniqueScoreSegmented` | `technique_score_segmented` | `Float?` | Number in range [0-100]. |
| `repsPerformed` | `reps_performed` | `Int?` | Reps performed. |
| `repsPerformedPerfect` | `reps_performed_perfect` | `Int?` | Reps performed without form feedback (≤ `repsPerformed`). |
| `timeInPosition` | `time_in_position` | `Double?` | Seconds in position. |
| `timeInPositionPerfect` | `time_in_position_perfect` | `Double?` | Seconds in position without form feedback. |
| `peakRangeOfMotionScore` | `peak_range_of_motion_score` | `Float?` | Number in range [0-100]. |
| `peakRangeOfMotionDegrees` | `peak_range_of_motion_degrees` | `Float?` | Peak range of motion in degrees, when supported. |
| `feedbackList` | — | `[FormFeedbackTypeBr: Float]` | Occurrence ratio per form-feedback type. |
| `feedback` | `feedback` | `[String]?` | Form-feedback names that occurred. |
| `summaryBreakdown` | `summary_breakdown` | `SummaryBreakdown?` | Score breakdown (see below). |
| `paceLimitDetectedCount` | `pace_limit_detected_count` | `Int` | Times the minimum rep pace was not met. |
| `paceLimitSpokenCount` | `pace_limit_spoken_count` | `Int` | Times pace coaching was spoken. |
| `repPacePerSecond` | — | `Double?` | Reps per second for the whole exercise. |
| `avgRepTimeSeconds` | `avg_rep_time_seconds` | `Double?` | Average rep time. Requires `SMKitUIModel.enableExerciseSummaryTimingMetrics`. |
| `maxConsecutiveHoldSeconds` | `max_consecutive_hold_seconds` | `Double?` | Longest continuous hold. Requires `enableExerciseSummaryTimingMetrics`. |
| `maxConsecutivePerfectHoldSeconds` | `max_consecutive_perfect_hold_seconds` | `Double?` | Longest continuous hold without feedback. Requires `enableExerciseSummaryTimingMetrics`. |
| `adaptiveRomPercentage` | `adaptive_rom_percentage` | `Float?` | Adaptive ROM result, when `adaptiveRomFeedbackEnabled` is set. |
| `adaptiveRom` | `adaptive_rom` | `[String: Any]?` | Adaptive ROM details. |
| `mobilityFlowSummary` | `mobility_flow_summary` | `SMMobilityFlowSummary?` | Per-block results for a Mobility Flow exercise. |
| `dumbbellWeight` | `dumbbell_weight` | `SMDumbbellWeight?` | Weight used for a dumbbell exercise. |
| `uiElements` | `ui_elements` | `[String]?` | UI elements shown. |
| `instructionVideo` | `instruction_video` | `String?` | Instruction video used. |
| `voiceIntro` | `voice_intro` | `String?` | Intro audio used. |
| `voiceOutro` | `voice_outro` | `String?` | Outro audio used. |
| `scoreParams` | `score_params` | `[String: Any]?` | Scoring parameters used. |
| `stretchSetConfig` | `stretch_set_config` | `[String: Any]?` | Stretch-set configuration used. |
| `positionRepConfig` | `position_rep_config` | `[String: Any]?` | Position-rep configuration used. |
| `mobilityRepConfig` | `mobility_rep_config` | `[String: Any]?` | Mobility-rep configuration used. |

### ExerciseDynamicData

| Swift property | Type | Description |
|----------------|------|-------------|
| `targetReps` | `Int?` | Target reps for the exercise. |
| `dynamicInfo` | `SMExerciseDynamicInfo?` | Raw dynamic-exercise results. |

### ExerciseStaticData

| Swift property | Type | Description |
|----------------|------|-------------|
| `didPassTest` | `Bool?` | Whether the hold met its pass criteria. |
| `passCriteria` | `[String]?` | Form-feedback names used as pass criteria. |
| `staticInfo` | `SMExerciseStaticInfo?` | Raw static-exercise results. |

### SummaryBreakdown

| Swift property | Type | Description |
|----------------|------|-------------|
| `scoreFactor` | `Double` | The `ScoringParams.scoreFactor` used. |
| `performance` | `PerformanceBreakdown` | Performance score and type. Cast to `RepsPerformanceBreakdown` (`performedReps`, `targetReps`), `TimePerformanceBreakdown` (`timeInPosition`, `targetTime`), or `RomPerformanceBreakdown` (`peakRangeMotion`, `targetRomCriteria`). |
| `technique` | `TechniqueBreakdown` | Technique `score` and a list of `FeedbackBreakdown` (`type`, `rate`, `description`). |

## Minor Types

### UserData
| Swift property | Type | Description |
|----------------|------|-------------|
| `gender` | `Gender` | `.Female`, `.Male`, or `.Other` ("Rather not say"). |
| `birthday` | `Date` | User's birthday; age is derived from it. |

### WorkoutModificationEvent
| Swift property | Type | Description |
|----------------|------|-------------|
| `type` | `WorkoutModificationType` | `exerciseSwitched`, `restAdded`, `pairedExerciseSwitched`, or `pairedExerciseSkipped`. |
| `source` | `WorkoutModificationSource` | `host`, `pauseSuggestion`, `pauseManual`, or `sdkRecovery`. |
| `timestamp` | `String` | When the change happened. |
| `sourceDetector` | `String?` | The original exercise. |
| `appliedDetector` | `String?` | The exercise that replaced it. |
| `pairedDetector` | `String?` | The paired side exercise, for paired switches. |
| `restSeconds` | `Int?` | Added rest, for `restAdded`. |

### WorkoutConfig
| Swift property | Type | Description |
|----------------|------|-------------|
| `programId` | `String?` | Program identifier. |
| `week` | `Int` | Program week. |
| `bodyZone` | `BodyZone` | `.UpperBody`, `.LowerBody`, or `.FullBody`. |
| `difficultyLevel` | `WorkoutDifficulty` | `.LowDifficulty`, `.MidDifficulty`, or `.HighDifficulty`. |
| `workoutDuration` | `WorkoutDuration` | `.Short` or `.Long`. |
| `language` | `SencySupportedLanguage` | Program language. |
| `phonePosition` | `PhonePosition` | `.Floor` or `.Elevated`. |
| `shortIntro` | `Bool` | Whether short exercise intros are used. |

### ScoringParams
| Swift property | Type | Description |
|----------------|------|-------------|
| `type` | `ScoringType?` | `.reps`, `.time`, or `.rom`. |
| `scoreFactor` | `Double?` | Performance weight in range 0–1. |
| `targetReps` | `Int?` | Target reps (`.reps`). |
| `targetTime` | `Int?` | Target time in seconds (`.time`). |
| `targetRom` | `String?` | Target ROM feedback name (`.rom`). |
| `passCriteria` | `[String]?` | Optional form-feedback names used as pass criteria. |

### SencySupportedLanguage
| Name | Code |
|------|------|
| English | `en` |
| Hebrew | `he` |
| Mandarin | `zh` |

# Data

## Assessment Data

### AssessmentData
| Name                | Type              | Description                                                                                                  |
|---------------------|-------------------|--------------------------------------------------------------------------------------------------------------|
| session_id          | `String`          | Random 24 character string.                                                                                  |
| type                | `String`          | Either “FitnessAssessment” or “CustomAssessment”.                                                            |
| user_data           | `UserData`        | User details.                                                                                                |
| sdk_data            | `SdkData`         | SDK details.                                                                                                 |
| exercises           | `[ExerciseData]`  | List of exercises data.                                                                                      |
| start_time          | `Date`            | UTC format: "YYYY-MM-dd HH:mm:ss.SSSZ".                                                                      |
| end_time            | `Date`            | UTC format: "YYYY-MM-dd HH:mm:ss.SSSZ".                                                                      |
| total_time          | `Double`          | Time in seconds from session start to session end.                                                           |
| total_score         | `Int`             | Number in range [0-100].                                                                                     |
| total_score_segmented| `Int`             | Number in range [0-100].                                                                                     |

## Workout Data

### WorkoutData
| Name                | Type              | Description                                                                                                  |
|---------------------|-------------------|--------------------------------------------------------------------------------------------------------------|
| session_id          | `String`          | Random 24 character string.                                                                                  |
| type                | `String`          | Either “CustomWorkout” or “ProgramWorkout”.                                                                  |
| workout_details     | `WorkoutDetailsData` | Optional details of the workout.                                                                             |
| user_data           | `UserData`        | User details.                                                                                                |
| sdk_data            | `SdkData`         | SDK details.                                                                                                 |
| exercises           | `[ExerciseData]`  | List of exercises data.                                                                                      |
| start_time          | `Date`            | UTC format: "YYYY-MM-dd HH:mm:ss.SSSZ".                                                                      |
| end_time            | `Date`            | UTC format: "YYYY-MM-dd HH:mm:ss.SSSZ".                                                                      |
| total_time          | `Double`          | Time in seconds from session start to session end.                                                           |
| completion_ratio    | `Double`          | A number in range of [0-1] representing the ratio of successfully completed exercises.                       |

## Exercise Data

### ExerciseData
| Name                | Type              | Description                                                                                                  |
|---------------------|-------------------|--------------------------------------------------------------------------------------------------------------|
| session_id          | `String`          | Random 24 character string.                                                                                  |
| type                | `String`          | Either “CustomWorkout” or “ProgramWorkout”.                                                                  |
| exercise_info       | `ExerciseInfoData`| Details about the exercise.                                                                                  |
| start_time          | `Date`            | UTC format: "YYYY-MM-dd HH:mm:ss.SSSZ".                                                                      |
| end_time            | `Date`            | UTC format: "YYYY-MM-dd HH:mm:ss.SSSZ".                                                                      |
| total_time          | `Double`          | Time in seconds from session start to session end.                                                           |
| total_score         | `Float?`          | Optional, number in range [0-100].                                                                           |
| total_score_segmented| `Float?`          | Optional, number in range [0-100].                                                                           |
| performance_score   | `Float?`          | Optional, number in range [0-100].                                                                           |
| performance_score_segmented| `Float?`    | Optional, number in range [0-100].                                                                           |
| technique_score     | `Float?`          | Optional, number in range [0-100].                                                                           |
| technique_score_segmented | `Float?`    | Optional, number in range [0-100].                                                                           |
| reps_performed      | `Int?`            | Optional, positive number.                                                                                   |
| reps_perfomed_perfect | `Int?`          | Optional, positive number (<= reps_performed).                                                               |
| time_in_position    | `Float?`          | Optional, positive number in seconds. Total time in position.                                                |
| time_in_position_perfect | `Float?`     | Optional, positive number in seconds. Total time in position.                                                |
| peak_range_of_motion_score | `Float?`   | Optional, number in range [0-100].                                                                           |
| feedback            | `[FormFeedbackType:Float]?` | Optional, pairs feedback occurrence ratio by feedback type.                                                  |


## Minor Types

### UserData
| Name                | Type              | Description                                                                                                  |
|---------------------|-------------------|--------------------------------------------------------------------------------------------------------------|
| age                 | `Int?`            | Optional, user's age in years (rounded).                                                                     |
| gender              | `String?`         | Optional, either “male” or “female”.                                                                         |

### WorkoutDetailsData
| Name                | Type              | Description                                                                                                  |
|---------------------|-------------------|--------------------------------------------------------------------------------------------------------------|
| program_id          | `String`          | Unique program id.                                                                                           |
| week                | `Int`             | Number greater than 0.                                                                                       |
| body_zone           | `String`          | Either “upper”, “lower”, or “full”.                                                                          |
| difficulty_level    | `String`          | Either “high”, “med”, or “low”.                                                                              |
| duration            | `String`          | Either “long” or “short”.                                                                                    |

### ExerciseInfoData
| Name                | Type              | Description                                                                                                  |
|---------------------|-------------------|--------------------------------------------------------------------------------------------------------------|
| exercise_id         | `String`          | Exercise id.                                                                                                 |
| total_time          | `Int?`            | Optional, exercise total time in seconds (to be used in exercise timer).                                      |
| scoring_params      | `ScoringParamsData` | Scoring params information.                                                                                  |
| ui_elements         | `[String]`        | “timer”, “repsCounter”, “gaugeOfMotion”.                                                                     |
| instruction_video   | `String?`         | Optional, file name.                                                                                         |
| voice_intro         | `String?`         | Optional, file name.                                                                                         |
| voice_outro         | `String?`         | Optional, file name.                                                                                         |
| pretty_name         | `String`          | Exercise display name.                                                                                       |


### ScoringParamsData
| Name                | Type              | Description                                                                                                  |
|---------------------|-------------------|--------------------------------------------------------------------------------------------------------------|
| target_reps         | `Int?`            | Optional, positive number.                                                                                   |
| target_time         | `Int?`            | Optional, positive number.                                                                                   |
| target_rom          | `FormFeedbackType?` | Optional, feedback type.                                                                                     |
| pass_criteria       | `[FormFeedbackType]?` | Optional, list of form checks to be used as pass criteria for scoring.                                        |

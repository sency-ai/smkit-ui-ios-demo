# Data

#### `ExerciseData`
| Type              | Format                                                         | Description                                                                                                  |
|-------------------|----------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| sessionId         | `String`                                                       | The identifier for the session in which the exercise was performed.                                          |
| prettyName        | `String`                                                       | The user-friendly name of the exercise activity.                                                             |
| name              | `String`                                                       | The technical name identifier for the exercise activity.                                                     |
| targetTime        | `Double?`                                                      | The targeted duration for the exercise session in seconds (optional).                                        |
| startTime         | `String`                                                       | The start time of the exercise session in "YYYY-MM-dd HH:mm:ss.SSSZ" format.                                 |
| endTime           | `String`                                                       | The end time of the exercise session in "YYYY-MM-dd HH:mm:ss.SSSZ" format.                                   |
| totalTime         | `Double`                                                       | The total time taken for the exercise session in seconds.                                                    |
| performanceScore  | `Float`                                                        | The score representing the user's performance in the exercise.                                               |
| techniqueScore    | `Float`                                                        | The score representing the user's technique during the exercise.                                             |
| totalScore        | `Float`                                                        | The final calculated score for the exercise session, considering both performance and technique.             |

#### `WorkoutSummaryData`
| Type              | Format                                 | Description                                                                                                  |
|-------------------|----------------------------------------|--------------------------------------------------------------------------------------------------------------|
| sessionId         | `String`                               | A unique identifier for the workout session, generated as a UUID string.                                     |
| exercises         | `[ExerciseData]`                       | An array of `ExerciseData` objects representing each exercise performed in the session.                      |
| score             | `Int`                                  | The overall score for the workout session based on the exercises' scores.                                    |
| completionRatio   | `Float`                                | A float value representing the ratio of exercises completed successfully over the total number of exercises. |
| startTime         | `String`                               | The start time of the workout session in "YYYY-MM-dd HH:mm:ss.SSSZ" format.                                  |
| endTime           | `String`                               | The end time of the workout session in "YYYY-MM-dd HH:mm:ss.SSSZ" format.                                    |
| totalTime         | `Double`                               | The total time taken for the workout session in seconds.                                                     |
| startDate         | `Date`                                 | The start date and time of the workout session.                                                             |
| finishedExercises | `Float`                                | The count of exercises that have been completed in the session.                                             |


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

# Instruction Video Behavior

This document explains the behavior and configuration options for instruction videos in the SDK.

## Overview
Instruction videos serve as a guide for users, demonstrating proper technique and posture for various activities. The behavior of the instruction video is determined by the provided value. Below are the scenarios and configurations:

---

### 1. **No Video Instruction (Value is Null)**  
If the value provided for the instruction video is `null`, no video instruction will be displayed.  
- **Use Case**: Suitable for activities that do not require visual guidance or when an instruction video is not applicable.  
- **Behavior**: The SDK will not display a video instruction
- **Example**: 

```swift
SMExercise(
    name: "High Knees",
    exerciseIntro: "Exericse Intro URL",
    totalSeconds: 15,
    videoInstruction: nil,
    uiElements: [.timer, .repsCounter],
    detector: "HighKnees",
    exerciseClosure: "Exericse Closure URL"
)
```

---

### 2. **Using Default Sency Video Instructions**  
You can provide a detector name to retrieve the default instruction video from Sency’s library.  
- **Requirements**: Ensure the detector name is a valid.  
- **Behavior**: The system will automatically fetch and display the corresponding default video instruction.  
- **Example**:

```swift
SMExercise(
    name: "High Knees",
    exerciseIntro: "Exericse Intro URL",
    totalSeconds: 15,
    videoInstruction: "HighKnees",
    uiElements: [.timer, .repsCounter],
    detector: "HighKnees",
    exerciseClosure: "Exericse Closure URL"
)
```

---

### 3. **Custom Video Instruction (Local or Remote URL)**  
You can specify a custom video instruction by providing a URL. The URL can point to:  
- **Local Video Files**: Ensure the file path is accessible to the application.  
- **Remote Video Files**: Provide a valid and reachable remote URL.  
- **Behavior**: The system will display the video from the provided URL as the instruction guide.  
- **Example**:  
  - Local URL: 
  ```swift
  let localVideo = Bundle.main.url(forResource: "local_video", withExtension: "mp4")?.path

  SMExercise(
      name: "High Knees",
      exerciseIntro: "Exericse Intro URL",
      totalSeconds: 15,
      videoInstruction: localVideo,
      uiElements: [.timer, .repsCounter],
      detector: "HighKnees",
      exerciseClosure: "Exericse Closure URL"
  )
  ``` 
  - Remote URL:
  ```swift
  SMExercise(
      name: "High Knees",
      exerciseIntro: "Exericse Intro URL",
      totalSeconds: 15,
      videoInstruction: "https://file-examples.com/storage/fe9e1fdc506794bc3a14b35/2017/04/file_example_MP4_480_1_5MG.mp4",
      uiElements: [.timer, .repsCounter],
      detector: "HighKnees",
      exerciseClosure: "Exericse Closure URL"
  ),
  ```
---

## Summary of Behavior

| Value Type          | Behavior                                                              |
|----------------------|----------------------------------------------------------------------|
| `null`              | No video instruction displayed.                                      |
| `detector_name`     | Loads Sency’s default video instruction for the specified detector.   |
| `Local/Remote URL`  | Displays the custom video instruction from the provided URL.         |

---

## Notes  
- Ensure all URLs are valid and accessible to prevent playback issues.  
- If using a detector name, verify the name is correctly spelled and recognized by the system.  

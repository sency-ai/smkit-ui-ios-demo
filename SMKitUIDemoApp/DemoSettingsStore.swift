//
//  DemoSettingsStore.swift
//  SMKitUIDemoApp
//

import Foundation
import CoreGraphics
import SMKit
import SMKitUI

final class DemoSettingsStore {
    static let shared = DemoSettingsStore()

    private let defaults = UserDefaults.standard
    private let prefix = "smkitui.demo.settings."

    private init() {}

    struct Option<Value> {
        let title: String
        let value: Value
    }

    enum InstructionVideoMode: String {
        case defaultMode
        case mediumCycle
    }

    static let colorThemeOptions: [Option<UIColorTheme>] = [
        .init(title: "Blue", value: .blue),
        .init(title: "Green", value: .green),
        .init(title: "Purple", value: .purple),
        .init(title: "Orange", value: .orange),
        .init(title: "Silver", value: .silver),
        .init(title: "Gold", value: .gold),
        .init(title: "Pink", value: .pink)
    ]

    static let skeletonPresetOptions: [Option<SkeletonPreset>] = [
        .init(title: "Default", value: .default),
        .init(title: "Minimal Dots", value: .minimalDots),
        .init(title: "Thin Outline", value: .thinOutline),
        .init(title: "Monochrome Clean", value: .monochromeClean),
        .init(title: "Neon Glow", value: .neonGlow),
        .init(title: "Bold Highlight", value: .boldHighlight),
        .init(title: "Soft Fill", value: .softFill),
        .init(title: "Wireframe", value: .wireframe),
        .init(title: "High Contrast", value: .highContrast),
        .init(title: "Pastel", value: .pastel),
        .init(title: "Dark Outline", value: .darkOutline),
        .init(title: "Minimal Line", value: .minimalLine),
        .init(title: "Double Stroke", value: .doubleStroke),
        .init(title: "Gradient Ready", value: .gradientReady),
        .init(title: "Subtle Shadow", value: .subtleShadow),
        .init(title: "Classic", value: .classic),
        .init(title: "Athletic", value: .athletic),
        .init(title: "Premium", value: .premium),
        .init(title: "Hologram", value: .hologram),
        .init(title: "Matte", value: .matte),
        .init(title: "Neon Pulse", value: .neonPulse),
        .init(title: "Outline Only", value: .outlineOnly),
        .init(title: "Slim", value: .slim),
        .init(title: "Thick", value: .thick),
        .init(title: "Studio", value: .studio),
        .init(title: "Accessibility", value: .accessibility)
    ]

    static let skeletonConnectionOptions: [Option<SkeletonConnectionStyle>] = [
        .init(title: "None", value: .none),
        .init(title: "Dotted", value: .dotted),
        .init(title: "Dashed", value: .dashed),
        .init(title: "Solid", value: .solid),
        .init(title: "Long Dashed", value: .longDashed),
        .init(title: "Thin Dots", value: .thinDots),
        .init(title: "Dot Dashed", value: .dotDashed),
        .init(title: "Rounded", value: .rounded)
    ]

    static let skeletonJointOptions: [Option<SkeletonJointShape>] = [
        .init(title: "Circle", value: .circle),
        .init(title: "Square", value: .square),
        .init(title: "Triangle", value: .triangle),
        .init(title: "Diamond", value: .diamond),
        .init(title: "Star", value: .star),
        .init(title: "Hexagon", value: .hexagon)
    ]

    static let sessionLanguageOptions: [Option<SencySupportedLanguage>] = [
        .init(title: "English", value: .English),
        .init(title: "Hebrew", value: .Hebrew)
    ]

    static let endExerciseOptions: [Option<EndExercisePreferences>] = [
        .init(title: "Timer", value: .Default),
        .init(title: "Target Based", value: .TargetBased)
    ]

    static let counterOptions: [Option<CounterPreferences>] = [
        .init(title: "Default", value: .Default),
        .init(title: "Perfect Only", value: .PerfectOnly)
    ]

    static let instructionModeOptions: [Option<InstructionVideoMode>] = [
        .init(title: "Default", value: .defaultMode),
        .init(title: "Medium Cycle", value: .mediumCycle)
    ]

    var configureHighlightsOnNextLaunch: Bool {
        get { bool("configureHighlightsOnNextLaunch", default: false) }
        set { set(newValue, "configureHighlightsOnNextLaunch") }
    }

    var showPhoneCalibration: Bool {
        get { bool("showPhoneCalibration", default: true) }
        set { set(newValue, "showPhoneCalibration") }
    }

    var enableWorkoutContinuation: Bool {
        get { bool("enableWorkoutContinuation", default: false) }
        set { set(newValue, "enableWorkoutContinuation") }
    }

    var showDebugBoundingBox: Bool {
        get { bool("showDebugBoundingBox", default: false) }
        set { set(newValue, "showDebugBoundingBox") }
    }

    var skeletonHidden: Bool {
        get { bool("skeletonHidden", default: false) }
        set { set(newValue, "skeletonHidden") }
    }

    var allowAudioMixing: Bool {
        get { bool("allowAudioMixing", default: true) }
        set { set(newValue, "allowAudioMixing") }
    }

    var showExternalAudioControl: Bool {
        get { bool("showExternalAudioControl", default: true) }
        set { set(newValue, "showExternalAudioControl") }
    }

    var showTalkToJinniControl: Bool {
        get { bool("showTalkToJinniControl", default: false) }
        set { set(newValue, "showTalkToJinniControl") }
    }

    var enableButtonTutorial: Bool {
        get { bool("enableButtonTutorial", default: false) }
        set { set(newValue, "enableButtonTutorial") }
    }

    var enableJinniWakeWord: Bool {
        get { bool("enableJinniWakeWord", default: false) }
        set { set(newValue, "enableJinniWakeWord") }
    }

    var alwaysOnJinniWakeWordDuringWorkout: Bool {
        get { bool("alwaysOnJinniWakeWordDuringWorkout", default: false) }
        set { set(newValue, "alwaysOnJinniWakeWordDuringWorkout") }
    }

    var enableIntelligenceRest: Bool {
        get { bool("enableIntelligenceRest", default: false) }
        set { set(newValue, "enableIntelligenceRest") }
    }

    var playPhoneCalibrationAudio: Bool {
        get { bool("playPhoneCalibrationAudio", default: false) }
        set { set(newValue, "playPhoneCalibrationAudio") }
    }

    var playBodyCalibrationAudio: Bool {
        get { bool("playBodyCalibrationAudio", default: false) }
        set { set(newValue, "playBodyCalibrationAudio") }
    }

    var accuratePoseEstimation: Bool {
        get { bool("accuratePoseEstimation", default: true) }
        set { set(newValue, "accuratePoseEstimation") }
    }

    var enableWatchCompanion: Bool {
        get { bool("enableWatchCompanion", default: false) }
        set { set(newValue, "enableWatchCompanion") }
    }

    var enableHeartRateRest: Bool {
        get { bool("enableHeartRateRest", default: false) }
        set { set(newValue, "enableHeartRateRest") }
    }

    var startTimerOnFirstActivity: Bool {
        get { bool("startTimerOnFirstActivity", default: true) }
        set { set(newValue, "startTimerOnFirstActivity") }
    }

    var enablePhoneMovementCountPrevention: Bool {
        get { bool("enablePhoneMovementCountPrevention", default: false) }
        set { set(newValue, "enablePhoneMovementCountPrevention") }
    }

    var enableVariationMismatchFeedback: Bool {
        get { bool("enableVariationMismatchFeedback", default: false) }
        set { set(newValue, "enableVariationMismatchFeedback") }
    }

    var colorThemeIndex: Int {
        get { clampedInt("colorThemeIndex", default: 1, range: 0...(Self.colorThemeOptions.count - 1)) }
        set { set(clamp(newValue, 0...(Self.colorThemeOptions.count - 1)), "colorThemeIndex") }
    }

    var skeletonPresetIndex: Int {
        get { clampedInt("skeletonPresetIndex", default: 0, range: 0...(Self.skeletonPresetOptions.count - 1)) }
        set { set(clamp(newValue, 0...(Self.skeletonPresetOptions.count - 1)), "skeletonPresetIndex") }
    }

    var skeletonConnectionIndex: Int {
        get { clampedInt("skeletonConnectionIndex", default: 3, range: 0...(Self.skeletonConnectionOptions.count - 1)) }
        set { set(clamp(newValue, 0...(Self.skeletonConnectionOptions.count - 1)), "skeletonConnectionIndex") }
    }

    var skeletonJointIndex: Int {
        get { clampedInt("skeletonJointIndex", default: 0, range: 0...(Self.skeletonJointOptions.count - 1)) }
        set { set(clamp(newValue, 0...(Self.skeletonJointOptions.count - 1)), "skeletonJointIndex") }
    }

    var skeletonDotsOpacity: Double {
        get { double("skeletonDotsOpacity", default: 1) }
        set { set(clamp(newValue, 0...1), "skeletonDotsOpacity") }
    }

    var skeletonConnectionsOpacity: Double {
        get { double("skeletonConnectionsOpacity", default: 1) }
        set { set(clamp(newValue, 0...1), "skeletonConnectionsOpacity") }
    }

    var skeletonDotsGlow: Double {
        get { double("skeletonDotsGlow", default: 0) }
        set { set(clamp(newValue, 0...1), "skeletonDotsGlow") }
    }

    var skeletonConnectionsGlow: Double {
        get { double("skeletonConnectionsGlow", default: 0) }
        set { set(clamp(newValue, 0...1), "skeletonConnectionsGlow") }
    }

    var skeletonLineWidthScale: Double {
        get { double("skeletonLineWidthScale", default: 1) }
        set { set(clamp(newValue, 0.5...2), "skeletonLineWidthScale") }
    }

    var skeletonOutlineScale: Double {
        get { double("skeletonOutlineScale", default: 1) }
        set { set(clamp(newValue, 0.5...2), "skeletonOutlineScale") }
    }

    var skeletonSoftness: Double {
        get { double("skeletonSoftness", default: 0) }
        set { set(clamp(newValue, 0...1), "skeletonSoftness") }
    }

    var skeletonAnimationDuration: Double {
        get { double("skeletonAnimationDuration", default: 0) }
        set { set(clamp(newValue, 0...0.05), "skeletonAnimationDuration") }
    }

    var workoutContinuationTimerDuration: Double {
        get { double("workoutContinuationTimerDuration", default: 10) }
        set { set(clamp(newValue, 1...60), "workoutContinuationTimerDuration") }
    }

    var heartRateRestThreshold: Int {
        get { clampedInt("heartRateRestThreshold", default: 160, range: 80...220) }
        set { set(clamp(newValue, 80...220), "heartRateRestThreshold") }
    }

    var instructionModeIndex: Int {
        get { clampedInt("instructionModeIndex", default: 0, range: 0...(Self.instructionModeOptions.count - 1)) }
        set { set(clamp(newValue, 0...(Self.instructionModeOptions.count - 1)), "instructionModeIndex") }
    }

    var instructionMediumCycles: Int {
        get { clampedInt("instructionMediumCycles", default: 2, range: 1...5) }
        set { set(clamp(newValue, 1...5), "instructionMediumCycles") }
    }

    var sessionLanguageIndex: Int {
        get { clampedInt("sessionLanguageIndex", default: 0, range: 0...(Self.sessionLanguageOptions.count - 1)) }
        set { set(clamp(newValue, 0...(Self.sessionLanguageOptions.count - 1)), "sessionLanguageIndex") }
    }

    var phoneCalibrationLanguageIndex: Int {
        get { clampedInt("phoneCalibrationLanguageIndex", default: 0, range: 0...(Self.sessionLanguageOptions.count - 1)) }
        set { set(clamp(newValue, 0...(Self.sessionLanguageOptions.count - 1)), "phoneCalibrationLanguageIndex") }
    }

    var endExercisePreferenceIndex: Int {
        get { clampedInt("endExercisePreferenceIndex", default: 0, range: 0...(Self.endExerciseOptions.count - 1)) }
        set { set(clamp(newValue, 0...(Self.endExerciseOptions.count - 1)), "endExercisePreferenceIndex") }
    }

    var counterPreferenceIndex: Int {
        get { clampedInt("counterPreferenceIndex", default: 0, range: 0...(Self.counterOptions.count - 1)) }
        set { set(clamp(newValue, 0...(Self.counterOptions.count - 1)), "counterPreferenceIndex") }
    }

    var jinniWakeWordPhrase: String {
        get {
            let value = defaults.string(forKey: key("jinniWakeWordPhrase")) ?? "wake up jinni"
            return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "wake up jinni" : value
        }
        set { defaults.set(newValue, forKey: key("jinniWakeWordPhrase")) }
    }

    var jinniVoiceSilenceSeconds: Double {
        get { double("jinniVoiceSilenceSeconds", default: 2) }
        set { set(clamp(newValue, 0.5...5), "jinniVoiceSilenceSeconds") }
    }

    var jinniWakeWordGuidanceGuardSeconds: Double {
        get { double("jinniWakeWordGuidanceGuardSeconds", default: 1.25) }
        set { set(clamp(newValue, 0...5), "jinniWakeWordGuidanceGuardSeconds") }
    }

    var skeletonDotsInnerColorIndex: Int {
        get { optionalColorIndex("skeletonDotsInnerColorIndex") }
        set { set(newValue, "skeletonDotsInnerColorIndex") }
    }

    var skeletonDotsOuterColorIndex: Int {
        get { optionalColorIndex("skeletonDotsOuterColorIndex") }
        set { set(newValue, "skeletonDotsOuterColorIndex") }
    }

    var skeletonConnectionsInnerColorIndex: Int {
        get { optionalColorIndex("skeletonConnectionsInnerColorIndex") }
        set { set(newValue, "skeletonConnectionsInnerColorIndex") }
    }

    var skeletonConnectionsOuterColorIndex: Int {
        get { optionalColorIndex("skeletonConnectionsOuterColorIndex") }
        set { set(newValue, "skeletonConnectionsOuterColorIndex") }
    }

    var allowedPauseTypes: [PauseAlertType] {
        get {
            guard let rawValues = defaults.array(forKey: key("allowedPauseTypes")) as? [String], !rawValues.isEmpty else {
                return PauseAlertType.allCases
            }
            let values = rawValues.compactMap(PauseAlertType.init(rawValue:))
            return values.isEmpty ? PauseAlertType.allCases : values
        }
        set {
            let values = newValue.isEmpty ? PauseAlertType.allCases : newValue
            defaults.set(values.map(\.rawValue), forKey: key("allowedPauseTypes"))
        }
    }

    var selectedColorTheme: UIColorTheme { Self.colorThemeOptions[colorThemeIndex].value }
    var selectedSkeletonPreset: SkeletonPreset { Self.skeletonPresetOptions[skeletonPresetIndex].value }
    var selectedSkeletonConnection: SkeletonConnectionStyle { Self.skeletonConnectionOptions[skeletonConnectionIndex].value }
    var selectedSkeletonJoint: SkeletonJointShape { Self.skeletonJointOptions[skeletonJointIndex].value }
    var selectedSessionLanguage: SencySupportedLanguage { Self.sessionLanguageOptions[sessionLanguageIndex].value }
    var selectedPhoneCalibrationLanguage: SencySupportedLanguage { Self.sessionLanguageOptions[phoneCalibrationLanguageIndex].value }
    var selectedEndExercisePreference: EndExercisePreferences { Self.endExerciseOptions[endExercisePreferenceIndex].value }
    var selectedCounterPreference: CounterPreferences { Self.counterOptions[counterPreferenceIndex].value }
    var selectedInstructionMode: InstructionVideoMode { Self.instructionModeOptions[instructionModeIndex].value }

    func colorOption(for index: Int) -> SkeletonColorOption? {
        guard index > 0 else { return nil }
        return SkeletonColorOption(rawValue: index - 1)
    }

    func applyToSDK() {
        SMKitUIModel.showDebugBoundingBox = false
        SMKitUIModel.colorTheme = selectedColorTheme
        SMKitUIModel.skeletonHidden = skeletonHidden
        SMKitUIModel.skeletonPreset = selectedSkeletonPreset
        SMKitUIModel.skeletonConnectionStyle = selectedSkeletonConnection
        SMKitUIModel.skeletonJointShape = selectedSkeletonJoint
        SMKitUIModel.skeletonDotsOpacity = CGFloat(skeletonDotsOpacity)
        SMKitUIModel.skeletonConnectionsOpacity = CGFloat(skeletonConnectionsOpacity)
        SMKitUIModel.skeletonDotsInnerColorOption = colorOption(for: skeletonDotsInnerColorIndex)
        SMKitUIModel.skeletonDotsOuterColorOption = colorOption(for: skeletonDotsOuterColorIndex)
        SMKitUIModel.skeletonConnectionsInnerColorOption = colorOption(for: skeletonConnectionsInnerColorIndex)
        SMKitUIModel.skeletonConnectionsOuterColorOption = colorOption(for: skeletonConnectionsOuterColorIndex)
        SMKitUIModel.skeletonDotsGlow = CGFloat(skeletonDotsGlow)
        SMKitUIModel.skeletonConnectionsGlow = CGFloat(skeletonConnectionsGlow)
        SMKitUIModel.skeletonLineWidthScale = CGFloat(skeletonLineWidthScale)
        SMKitUIModel.skeletonOutlineScale = CGFloat(skeletonOutlineScale)
        SMKitUIModel.skeletonSoftness = CGFloat(skeletonSoftness)
        SMKitUIModel.skeletonAnimationDuration = skeletonAnimationDuration
        SMKitUIModel.workoutContinuationTimerDuration = workoutContinuationTimerDuration
        SMKitUIModel.allowAudioMixing = allowAudioMixing
        SMKitUIModel.showExternalAudioControl = showExternalAudioControl
        SMKitUIModel.showTalkToJinniControl = false
        SMKitUIModel.enableButtonTutorial = enableButtonTutorial
        SMKitUIModel.enableJinniWakeWord = false
        SMKitUIModel.alwaysOnJinniWakeWordDuringWorkout = false
        SMKitUIModel.jinniWakeWordPhrase = "Hey Jinni"
        SMKitUIModel.jinniVoiceSilenceSeconds = 1.2
        SMKitUIModel.jinniWakeWordGuidanceGuardSeconds = 1
        SMKitUIModel.enableIntelligenceRest = enableIntelligenceRest
        SMKitUIModel.playPhoneCalibrationAudio = playPhoneCalibrationAudio
        SMKitUIModel.playBodyCalibrationAudio = playBodyCalibrationAudio
        SMKitUIModel.accuratePoseEstimation = accuratePoseEstimation
        SMKitUIModel.enableWatchCompanion = enableWatchCompanion
        SMKitUIModel.enableHeartRateRest = enableHeartRateRest
        SMKitUIModel.heartRateRestThreshold = heartRateRestThreshold
        SMKitUIModel.startTimerOnFirstActivity = startTimerOnFirstActivity
        SMKitUIModel.enablePhoneMovementCountPrevention = enablePhoneMovementCountPrevention
        SMKitUIModel.enableVariationMismatchFeedback = enableVariationMismatchFeedback

        let displayMode: VideoDisplayMode = selectedInstructionMode == .mediumCycle ? .mediumCycle : .default
        SMKitUIModel.instructionVideoConfig = InstructionVideoConfig(
            displayMode: displayMode,
            mediumSizeCycles: instructionMediumCycles
        )
        SMKitUIModel.setSessionLanguage(language: selectedSessionLanguage)
        SMKitUIModel.setPhoneCalibrationLanguage(language: selectedPhoneCalibrationLanguage)
        SMKitUIModel.setEndExercisePreferences(endExercisePreferences: selectedEndExercisePreference)
        SMKitUIModel.setCounterPreferences(counterPreferences: selectedCounterPreference)
        try? SMKitUIModel.setAllowedPauseTypes(types: allowedPauseTypes)
    }

    private func optionalColorIndex(_ name: String) -> Int {
        let maxValue = SkeletonColorOption.allCases.count
        return clampedInt(name, default: 0, range: 0...maxValue)
    }

    private func bool(_ name: String, default defaultValue: Bool) -> Bool {
        let fullKey = key(name)
        return defaults.object(forKey: fullKey) == nil ? defaultValue : defaults.bool(forKey: fullKey)
    }

    private func double(_ name: String, default defaultValue: Double) -> Double {
        let fullKey = key(name)
        return defaults.object(forKey: fullKey) == nil ? defaultValue : defaults.double(forKey: fullKey)
    }

    private func clampedInt(_ name: String, default defaultValue: Int, range: ClosedRange<Int>) -> Int {
        let fullKey = key(name)
        let value = defaults.object(forKey: fullKey) == nil ? defaultValue : defaults.integer(forKey: fullKey)
        return clamp(value, range)
    }

    private func set(_ value: Bool, _ name: String) {
        defaults.set(value, forKey: key(name))
    }

    private func set(_ value: Int, _ name: String) {
        defaults.set(value, forKey: key(name))
    }

    private func set(_ value: Double, _ name: String) {
        defaults.set(value, forKey: key(name))
    }

    private func key(_ name: String) -> String {
        prefix + name
    }

    private func clamp(_ value: Int, _ range: ClosedRange<Int>) -> Int {
        min(max(value, range.lowerBound), range.upperBound)
    }

    private func clamp(_ value: Double, _ range: ClosedRange<Double>) -> Double {
        min(max(value, range.lowerBound), range.upperBound)
    }
}

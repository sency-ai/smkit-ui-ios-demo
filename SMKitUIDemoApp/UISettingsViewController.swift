//
//  UISettingsViewController.swift
//  SMKitUIDemoApp
//

import UIKit
import SMKitUI

final class UISettingsViewController: UIViewController {
    private let settings = DemoSettingsStore.shared
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let rowHeight: CGFloat = 44

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UI Settings"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
        ])

        buildSettings()
    }

    private func buildSettings() {
        addSection("Demo")
        addSwitchRow(title: "Show phone calibration", isOn: settings.showPhoneCalibration) { [weak self] value in
            self?.settings.showPhoneCalibration = value
        }

        addSection("Appearance")
        addOptionRow(title: "Color theme", options: DemoSettingsStore.colorThemeOptions, selectedIndex: settings.colorThemeIndex) { [weak self] index in
            self?.settings.colorThemeIndex = index
            self?.apply()
        }
        addSwitchRow(title: "Hide skeleton", isOn: settings.skeletonHidden) { [weak self] value in
            self?.settings.skeletonHidden = value
            self?.apply()
        }
        addOptionRow(title: "Skeleton preset", options: DemoSettingsStore.skeletonPresetOptions, selectedIndex: settings.skeletonPresetIndex) { [weak self] index in
            self?.settings.skeletonPresetIndex = index
            self?.apply()
        }
        addOptionRow(title: "Connection style", options: DemoSettingsStore.skeletonConnectionOptions, selectedIndex: settings.skeletonConnectionIndex) { [weak self] index in
            self?.settings.skeletonConnectionIndex = index
            self?.apply()
        }
        addOptionRow(title: "Joint shape", options: DemoSettingsStore.skeletonJointOptions, selectedIndex: settings.skeletonJointIndex) { [weak self] index in
            self?.settings.skeletonJointIndex = index
            self?.apply()
        }
        addSliderRow(title: "Dots opacity", value: settings.skeletonDotsOpacity, range: 0...1) { [weak self] value in
            self?.settings.skeletonDotsOpacity = value
            self?.apply()
        }
        addSliderRow(title: "Connections opacity", value: settings.skeletonConnectionsOpacity, range: 0...1) { [weak self] value in
            self?.settings.skeletonConnectionsOpacity = value
            self?.apply()
        }
        addColorOptionRow(title: "Dots inner color", selectedIndex: settings.skeletonDotsInnerColorIndex) { [weak self] index in
            self?.settings.skeletonDotsInnerColorIndex = index
            self?.apply()
        }
        addColorOptionRow(title: "Dots outer color", selectedIndex: settings.skeletonDotsOuterColorIndex) { [weak self] index in
            self?.settings.skeletonDotsOuterColorIndex = index
            self?.apply()
        }
        addColorOptionRow(title: "Connections inner color", selectedIndex: settings.skeletonConnectionsInnerColorIndex) { [weak self] index in
            self?.settings.skeletonConnectionsInnerColorIndex = index
            self?.apply()
        }
        addColorOptionRow(title: "Connections outer color", selectedIndex: settings.skeletonConnectionsOuterColorIndex) { [weak self] index in
            self?.settings.skeletonConnectionsOuterColorIndex = index
            self?.apply()
        }
        addSliderRow(title: "Dots glow", value: settings.skeletonDotsGlow, range: 0...1) { [weak self] value in
            self?.settings.skeletonDotsGlow = value
            self?.apply()
        }
        addSliderRow(title: "Connections glow", value: settings.skeletonConnectionsGlow, range: 0...1) { [weak self] value in
            self?.settings.skeletonConnectionsGlow = value
            self?.apply()
        }
        addSliderRow(title: "Line width scale", value: settings.skeletonLineWidthScale, range: 0.5...2) { [weak self] value in
            self?.settings.skeletonLineWidthScale = value
            self?.apply()
        }
        addSliderRow(title: "Outline scale", value: settings.skeletonOutlineScale, range: 0.5...2) { [weak self] value in
            self?.settings.skeletonOutlineScale = value
            self?.apply()
        }
        addSliderRow(title: "Softness", value: settings.skeletonSoftness, range: 0...1) { [weak self] value in
            self?.settings.skeletonSoftness = value
            self?.apply()
        }
        addSliderRow(title: "Animation duration", value: settings.skeletonAnimationDuration, range: 0...0.05, precision: 3) { [weak self] value in
            self?.settings.skeletonAnimationDuration = value
            self?.apply()
        }

        addSection("Audio and Calibration")
        addSwitchRow(title: "Allow audio mixing", isOn: settings.allowAudioMixing) { [weak self] value in
            self?.settings.allowAudioMixing = value
            self?.apply()
        }
        addSwitchRow(title: "Show external audio control", isOn: settings.showExternalAudioControl) { [weak self] value in
            self?.settings.showExternalAudioControl = value
            self?.apply()
        }
        addSwitchRow(title: "Phone calibration audio", isOn: settings.playPhoneCalibrationAudio) { [weak self] value in
            self?.settings.playPhoneCalibrationAudio = value
            self?.apply()
        }
        addSwitchRow(title: "Body calibration audio", isOn: settings.playBodyCalibrationAudio) { [weak self] value in
            self?.settings.playBodyCalibrationAudio = value
            self?.apply()
        }
        addOptionRow(title: "Session language", options: DemoSettingsStore.sessionLanguageOptions, selectedIndex: settings.sessionLanguageIndex) { [weak self] index in
            self?.settings.sessionLanguageIndex = index
            self?.apply()
        }
        addOptionRow(title: "Phone calibration language", options: DemoSettingsStore.sessionLanguageOptions, selectedIndex: settings.phoneCalibrationLanguageIndex) { [weak self] index in
            self?.settings.phoneCalibrationLanguageIndex = index
            self?.apply()
        }

        addSection("Session Behavior")
        addSwitchRow(title: "Accurate pose estimation", isOn: settings.accuratePoseEstimation) { [weak self] value in
            self?.settings.accuratePoseEstimation = value
            self?.apply()
        }
        addSwitchRow(title: "Intelligence rest", isOn: settings.enableIntelligenceRest) { [weak self] value in
            self?.settings.enableIntelligenceRest = value
            self?.apply()
        }
        addSwitchRow(title: "Watch companion", isOn: settings.enableWatchCompanion) { [weak self] value in
            self?.settings.enableWatchCompanion = value
            self?.apply()
        }
        addSwitchRow(title: "Heart-rate rest", isOn: settings.enableHeartRateRest) { [weak self] value in
            self?.settings.enableHeartRateRest = value
            self?.apply()
        }
        addStepperRow(title: "Heart-rate rest threshold", value: Double(settings.heartRateRestThreshold), range: 80...220, step: 5, format: { "\(Int($0)) bpm" }) { [weak self] value in
            self?.settings.heartRateRestThreshold = Int(value)
            self?.apply()
        }
        addSwitchRow(title: "Timer starts on first activity", isOn: settings.startTimerOnFirstActivity) { [weak self] value in
            self?.settings.startTimerOnFirstActivity = value
            self?.apply()
        }
        addSwitchRow(title: "Prevent count while phone moves", isOn: settings.enablePhoneMovementCountPrevention) { [weak self] value in
            self?.settings.enablePhoneMovementCountPrevention = value
            self?.apply()
        }
        addSwitchRow(title: "Variation mismatch feedback", isOn: settings.enableVariationMismatchFeedback) { [weak self] value in
            self?.settings.enableVariationMismatchFeedback = value
            self?.apply()
        }
        addSwitchRow(title: "Button hover tutorial", isOn: settings.enableButtonTutorial) { [weak self] value in
            self?.settings.enableButtonTutorial = value
            self?.apply()
        }
        addStepperRow(title: "Continuation timer", value: settings.workoutContinuationTimerDuration, range: 1...60, step: 1, format: { "\(Int($0))s" }) { [weak self] value in
            self?.settings.workoutContinuationTimerDuration = value
            self?.apply()
        }
        addOptionRow(title: "End exercise", options: DemoSettingsStore.endExerciseOptions, selectedIndex: settings.endExercisePreferenceIndex) { [weak self] index in
            self?.settings.endExercisePreferenceIndex = index
            self?.apply()
        }
        addOptionRow(title: "Counter preference", options: DemoSettingsStore.counterOptions, selectedIndex: settings.counterPreferenceIndex) { [weak self] index in
            self?.settings.counterPreferenceIndex = index
            self?.apply()
        }

        addSection("Instruction Video")
        addOptionRow(title: "Display mode", options: DemoSettingsStore.instructionModeOptions, selectedIndex: settings.instructionModeIndex) { [weak self] index in
            self?.settings.instructionModeIndex = index
            self?.apply()
        }
        addStepperRow(title: "Medium cycles", value: Double(settings.instructionMediumCycles), range: 1...5, step: 1, format: { "\(Int($0))" }) { [weak self] value in
            self?.settings.instructionMediumCycles = Int(value)
            self?.apply()
        }

        addSection("Pause Buttons")
        PauseAlertType.allCases.forEach { addPauseTypeRow($0) }
    }

    private func addSection(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        contentStack.addArrangedSubview(label)
        contentStack.setCustomSpacing(6, after: label)
    }

    private func addSwitchRow(title: String, isOn: Bool, onChange: @escaping (Bool) -> Void) {
        let row = UIView()
        let label = rowLabel(title)
        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addAction(UIAction { action in
            guard let sender = action.sender as? UISwitch else { return }
            onChange(sender.isOn)
        }, for: .valueChanged)
        row.addSubview(label)
        row.addSubview(toggle)
        addHorizontalRow(row, label: label, trailingView: toggle)
    }

    private func addOptionRow<Value>(
        title: String,
        options: [DemoSettingsStore.Option<Value>],
        selectedIndex: Int,
        onSelect: @escaping (Int) -> Void
    ) {
        let row = UIView()
        let label = rowLabel(title)
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .trailing
        button.setTitle(options.indices.contains(selectedIndex) ? options[selectedIndex].title : "Select", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self, weak button] _ in
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            for (index, option) in options.enumerated() {
                alert.addAction(UIAlertAction(title: option.title, style: .default) { _ in
                    button?.setTitle(option.title, for: .normal)
                    onSelect(index)
                })
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(alert, animated: true)
        }, for: .touchUpInside)
        row.addSubview(label)
        row.addSubview(button)
        addHorizontalRow(row, label: label, trailingView: button)
    }

    private func addColorOptionRow(title: String, selectedIndex: Int, onSelect: @escaping (Int) -> Void) {
        let options = [DemoSettingsStore.Option(title: "Preset", value: -1)] +
            SkeletonColorOption.allCases.map { DemoSettingsStore.Option(title: $0.displayName, value: $0.rawValue) }
        addOptionRow(title: title, options: options, selectedIndex: selectedIndex, onSelect: onSelect)
    }

    private func addSliderRow(
        title: String,
        value: Double,
        range: ClosedRange<Double>,
        precision: Int = 2,
        onChange: @escaping (Double) -> Void
    ) {
        let label = rowLabel(title)
        let valueLabel = UILabel()
        valueLabel.text = formatted(value, precision: precision)
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let slider = UISlider()
        slider.minimumValue = Float(range.lowerBound)
        slider.maximumValue = Float(range.upperBound)
        slider.value = Float(value)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addAction(UIAction { action in
            guard let sender = action.sender as? UISlider else { return }
            let value = Double(sender.value)
            valueLabel.text = self.formatted(value, precision: precision)
            onChange(value)
        }, for: .valueChanged)

        let row = UIStackView(arrangedSubviews: [label, slider, valueLabel])
        row.axis = .vertical
        row.spacing = 4
        contentStack.addArrangedSubview(row)
    }

    private func addStepperRow(
        title: String,
        value: Double,
        range: ClosedRange<Double>,
        step: Double,
        format: @escaping (Double) -> String,
        onChange: @escaping (Double) -> Void
    ) {
        let row = UIView()
        let label = rowLabel(title)
        let valueLabel = UILabel()
        valueLabel.text = format(value)
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let stepper = UIStepper()
        stepper.minimumValue = range.lowerBound
        stepper.maximumValue = range.upperBound
        stepper.stepValue = step
        stepper.value = value
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.addAction(UIAction { action in
            guard let sender = action.sender as? UIStepper else { return }
            valueLabel.text = format(sender.value)
            onChange(sender.value)
        }, for: .valueChanged)

        row.addSubview(label)
        row.addSubview(valueLabel)
        row.addSubview(stepper)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: rowHeight),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: stepper.leadingAnchor, constant: -12),
            valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            stepper.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            stepper.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -12),
        ])
        contentStack.addArrangedSubview(row)
    }

    private func addTextFieldRow(title: String, value: String, onChange: @escaping (String) -> Void) {
        let label = rowLabel(title)
        let textField = UITextField()
        textField.text = value
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.addAction(UIAction { action in
            guard let sender = action.sender as? UITextField else { return }
            onChange(sender.text ?? "")
        }, for: .editingChanged)
        let row = UIStackView(arrangedSubviews: [label, textField])
        row.axis = .vertical
        row.spacing = 6
        contentStack.addArrangedSubview(row)
    }

    private func addPauseTypeRow(_ type: PauseAlertType) {
        let row = UIView()
        let label = rowLabel(pauseTitle(type))
        let toggle = UISwitch()
        toggle.isOn = settings.allowedPauseTypes.contains(type)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addAction(UIAction { [weak self, weak toggle] action in
            guard let self, let sender = action.sender as? UISwitch else { return }
            var selected = self.settings.allowedPauseTypes
            if sender.isOn {
                if !selected.contains(type) { selected.append(type) }
            } else {
                selected.removeAll { $0 == type }
            }
            guard !selected.isEmpty else {
                toggle?.setOn(true, animated: true)
                return
            }
            self.settings.allowedPauseTypes = selected
            self.apply()
        }, for: .valueChanged)
        row.addSubview(label)
        row.addSubview(toggle)
        addHorizontalRow(row, label: label, trailingView: toggle)
    }

    private func addHorizontalRow(_ row: UIView, label: UILabel, trailingView: UIView) {
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: rowHeight),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingView.leadingAnchor, constant: -12),
            trailingView.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            trailingView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        contentStack.addArrangedSubview(row)
    }

    private func rowLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func apply() {
        settings.applyToSDK()
    }

    private func formatted(_ value: Double, precision: Int) -> String {
        String(format: "%.\(precision)f", value)
    }

    private func pauseTitle(_ type: PauseAlertType) -> String {
        switch type {
        case .Quit: return "Pause: Quit"
        case .Skip: return "Pause: Skip"
        case .StartOver: return "Pause: Start over"
        case .Resume: return "Pause: Resume"
        case .Rest: return "Pause: Rest"
        case .Switch: return "Pause: Switch"
        @unknown default: return "Pause: \(String(describing: type))"
        }
    }

    @objc private func doneTapped() {
        dismiss(animated: true)
    }
}

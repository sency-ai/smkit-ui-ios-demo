//
//  BuildWorkoutViewController.swift
//  SMKitUIDemoApp
//

import UIKit
import SMBase
import SMKitUI

protocol BuildWorkoutViewControllerDelegate: AnyObject {
    func buildWorkoutViewController(
        _ controller: BuildWorkoutViewController,
        didStartWorkout exercises: [BuiltWorkoutExercise],
        continuationExercises: [BuiltWorkoutExercise]
    )
}

enum WorkoutPhonePositionChoice: Int {
    case sdkDefault
    case floor
    case elevated

    var phonePosition: PhonePosition? {
        switch self {
        case .sdkDefault: return nil
        case .floor: return .Floor
        case .elevated: return .Elevated
        }
    }
}

enum WorkoutTriStateChoice: Int {
    case sdkDefault
    case on
    case off

    var boolValue: Bool? {
        switch self {
        case .sdkDefault: return nil
        case .on: return true
        case .off: return false
        }
    }
}

struct BuiltWorkoutExercise: Equatable {
    let id: UUID
    var detector: String
    var duration: Int
    var phonePositionChoice: WorkoutPhonePositionChoice
    var guidanceChoice: WorkoutTriStateChoice
    var wideAngleChoice: WorkoutTriStateChoice
    var shortIntro: Bool
    var playPreExerciseCountdown: Bool
    var playRepMilestoneVoice: Bool
    var repMilestoneInterval: Int
    var playSoundOnEachRep: Bool
    var adaptiveRomFeedbackEnabled: Bool
    var adaptiveRomWarmupReps: Int
    var stretchSetEnabled: Bool
    var stretchSetRepetitions: Int
    var stretchSetSeconds: Int
    var stretchSetRestSeconds: Int

    init(detector: String, duration: Int) {
        self.id = UUID()
        self.detector = detector
        self.duration = duration
        self.phonePositionChoice = .sdkDefault
        self.guidanceChoice = .sdkDefault
        self.wideAngleChoice = .sdkDefault
        self.shortIntro = false
        self.playPreExerciseCountdown = false
        self.playRepMilestoneVoice = false
        self.repMilestoneInterval = 10
        self.playSoundOnEachRep = false
        self.adaptiveRomFeedbackEnabled = false
        self.adaptiveRomWarmupReps = 2
        self.stretchSetEnabled = false
        self.stretchSetRepetitions = 3
        self.stretchSetSeconds = 8
        self.stretchSetRestSeconds = 4
    }

    var stretchSetConfig: SMStretchSetConfig? {
        guard stretchSetEnabled else { return nil }
        return SMStretchSetConfig(
            enabled: true,
            repetitions: stretchSetRepetitions,
            secondsPerStretch: stretchSetSeconds,
            restSecondsBetweenStretches: stretchSetRestSeconds
        )
    }
}

final class BuildWorkoutViewController: UIViewController {
    weak var delegate: BuildWorkoutViewControllerDelegate?

    private enum Section {
        case available
        case main
        case continuation
    }

    private let settings = DemoSettingsStore.shared
    private let searchBar = UISearchBar()
    private let continuationRow = UIView()
    private let continuationSwitch = UISwitch()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let addTargetControl = UISegmentedControl(items: ["Workout", "Continuation"])
    private var startButton: UIBarButtonItem!
    private var clearButton: UIBarButtonItem!
    private var addTargetHeightConstraint: NSLayoutConstraint?
    private var tableTopConstraint: NSLayoutConstraint?
    private var availableDetectors: [String] = []
    private var filteredDetectors: [String] = []
    private var selectedExercises: [BuiltWorkoutExercise] = []
    private var continuationExercises: [BuiltWorkoutExercise] = []

    private var sections: [Section] {
        settings.enableWorkoutContinuation ? [.main, .continuation, .available] : [.main, .available]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Build Workout"
        view.backgroundColor = .systemBackground
        loadAvailableExercises()
        configureNavigation()
        configureLayout()
        updateStartState()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    private func loadAvailableExercises() {
        let supported = SMKitUIModel.getSupportedMovements() ?? []
        availableDetectors = Array(Set(supported))
            .filter { $0.caseInsensitiveCompare("Rowing") != .orderedSame }
            .sorted { Self.displayName(for: $0) < Self.displayName(for: $1) }
        filteredDetectors = availableDetectors
    }

    private func configureNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        startButton = UIBarButtonItem(title: "Start", style: .done, target: self, action: #selector(startTapped))
        clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearTapped))
        navigationItem.rightBarButtonItems = [startButton, editButtonItem, clearButton]
    }

    private func configureLayout() {
        searchBar.placeholder = "Search SDK exercises"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        let continuationLabel = UILabel()
        continuationLabel.text = "Enable workout continuation"
        continuationLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        continuationLabel.numberOfLines = 0
        continuationLabel.translatesAutoresizingMaskIntoConstraints = false
        continuationSwitch.isOn = settings.enableWorkoutContinuation
        continuationSwitch.translatesAutoresizingMaskIntoConstraints = false
        continuationSwitch.addAction(UIAction { [weak self] action in
            guard let self, let sender = action.sender as? UISwitch else { return }
            self.settings.enableWorkoutContinuation = sender.isOn
            self.updateContinuationControls(animated: true)
        }, for: .valueChanged)
        continuationRow.translatesAutoresizingMaskIntoConstraints = false
        continuationRow.addSubview(continuationLabel)
        continuationRow.addSubview(continuationSwitch)

        addTargetControl.selectedSegmentIndex = 0
        addTargetControl.isHidden = !settings.enableWorkoutContinuation
        addTargetControl.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(searchBar)
        view.addSubview(continuationRow)
        view.addSubview(addTargetControl)
        view.addSubview(tableView)

        let addTargetHeightConstraint = addTargetControl.heightAnchor.constraint(equalToConstant: settings.enableWorkoutContinuation ? 32 : 0)
        let tableTopConstraint = tableView.topAnchor.constraint(equalTo: addTargetControl.bottomAnchor, constant: settings.enableWorkoutContinuation ? 8 : 0)
        self.addTargetHeightConstraint = addTargetHeightConstraint
        self.tableTopConstraint = tableTopConstraint

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            continuationRow.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            continuationRow.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            continuationRow.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            continuationRow.heightAnchor.constraint(equalToConstant: 44),

            continuationLabel.leadingAnchor.constraint(equalTo: continuationRow.leadingAnchor),
            continuationLabel.trailingAnchor.constraint(lessThanOrEqualTo: continuationSwitch.leadingAnchor, constant: -12),
            continuationLabel.centerYAnchor.constraint(equalTo: continuationRow.centerYAnchor),
            continuationSwitch.trailingAnchor.constraint(equalTo: continuationRow.trailingAnchor),
            continuationSwitch.centerYAnchor.constraint(equalTo: continuationRow.centerYAnchor),

            addTargetControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            addTargetControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            addTargetControl.topAnchor.constraint(equalTo: continuationRow.bottomAnchor, constant: 4),
            addTargetHeightConstraint,

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableTopConstraint,
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func updateContinuationControls(animated: Bool) {
        let enabled = settings.enableWorkoutContinuation
        if !enabled {
            addTargetControl.selectedSegmentIndex = 0
        }
        addTargetControl.isHidden = !enabled
        addTargetHeightConstraint?.constant = enabled ? 32 : 0
        tableTopConstraint?.constant = enabled ? 8 : 0
        tableView.reloadData()
        updateStartState()

        guard animated else { return }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    private func addDetector(_ detector: String) {
        let item = BuiltWorkoutExercise(
            detector: detector,
            duration: Self.defaultDuration(for: detector)
        )
        let destinationSection: Section
        let destinationRow: Int
        if settings.enableWorkoutContinuation && addTargetControl.selectedSegmentIndex == 1 {
            continuationExercises.append(item)
            destinationSection = .continuation
            destinationRow = continuationExercises.count - 1
        } else {
            selectedExercises.append(item)
            destinationSection = .main
            destinationRow = selectedExercises.count - 1
        }
        tableView.reloadData()
        updateStartState()
        scrollToAddedExercise(section: destinationSection, row: destinationRow)
    }

    private func scrollToAddedExercise(section: Section, row: Int) {
        guard let sectionIndex = sections.firstIndex(where: { $0 == section }) else { return }
        tableView.scrollToRow(at: IndexPath(row: row, section: sectionIndex), at: .top, animated: true)
    }

    private func openEditor(for indexPath: IndexPath) {
        let section = sections[indexPath.section]
        switch section {
        case .main:
            let item = selectedExercises[indexPath.row]
            pushEditor(for: item) { [weak self] updated in
                self?.selectedExercises[indexPath.row] = updated
                self?.tableView.reloadData()
            }
        case .continuation:
            let item = continuationExercises[indexPath.row]
            pushEditor(for: item) { [weak self] updated in
                self?.continuationExercises[indexPath.row] = updated
                self?.tableView.reloadData()
            }
        case .available:
            break
        }
    }

    private func pushEditor(for item: BuiltWorkoutExercise, onSave: @escaping (BuiltWorkoutExercise) -> Void) {
        let editor = ExerciseConfigViewController(exercise: item, onSave: onSave)
        navigationController?.pushViewController(editor, animated: true)
    }

    private func updateStartState() {
        startButton?.isEnabled = !selectedExercises.isEmpty
        clearButton?.isEnabled = !selectedExercises.isEmpty || !continuationExercises.isEmpty
    }

    private static func defaultDuration(for detector: String) -> Int {
        if (try? SMKitUIModel.getExerciseType(type: detector)) == .Mobility {
            return 10
        }
        return 20
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func clearTapped() {
        selectedExercises.removeAll()
        continuationExercises.removeAll()
        tableView.reloadData()
        updateStartState()
    }

    @objc private func startTapped() {
        guard !selectedExercises.isEmpty else { return }
        delegate?.buildWorkoutViewController(
            self,
            didStartWorkout: selectedExercises,
            continuationExercises: settings.enableWorkoutContinuation ? continuationExercises : []
        )
    }

    fileprivate static func displayName(for detector: String) -> String {
        detector
            .replacingOccurrences(of: "QL", with: "Q L")
            .replacingOccurrences(of: "IT", with: "I T")
            .replacingOccurrences(of: "([a-z0-9])([A-Z])", with: "$1 $2", options: .regularExpression)
    }
}

extension BuildWorkoutViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            filteredDetectors = availableDetectors
        } else {
            filteredDetectors = availableDetectors.filter {
                $0.localizedCaseInsensitiveContains(query) ||
                BuildWorkoutViewController.displayName(for: $0).localizedCaseInsensitiveContains(query)
            }
        }
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}

extension BuildWorkoutViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .available: return filteredDetectors.count
        case .main: return selectedExercises.count
        case .continuation: return continuationExercises.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
        case .available:
            return "Available exercises"
        case .main:
            return "Workout (\(selectedExercises.count))"
        case .continuation:
            return "Continuation (\(continuationExercises.count))"
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch sections[section] {
        case .available:
            return filteredDetectors.isEmpty ? "No supported movements found." : "Tap an exercise to add it."
        case .main:
            return selectedExercises.isEmpty ? "Add at least one exercise to enable Start." : "Tap an exercise to edit settings. Use Edit to reorder or remove."
        case .continuation:
            return "Continuation exercises run only when the setting is enabled."
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ??
            UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.accessoryType = .none
        cell.selectionStyle = .default

        switch sections[indexPath.section] {
        case .available:
            let detector = filteredDetectors[indexPath.row]
            cell.textLabel?.text = BuildWorkoutViewController.displayName(for: detector)
            cell.detailTextLabel?.text = detector
            cell.imageView?.image = UIImage(systemName: "plus.circle")
        case .main:
            configureSelectedCell(cell, item: selectedExercises[indexPath.row], index: indexPath.row)
        case .continuation:
            configureSelectedCell(cell, item: continuationExercises[indexPath.row], index: indexPath.row)
        }

        return cell
    }

    private func configureSelectedCell(_ cell: UITableViewCell, item: BuiltWorkoutExercise, index: Int) {
        cell.textLabel?.text = "\(index + 1). \(BuildWorkoutViewController.displayName(for: item.detector))"
        cell.detailTextLabel?.text = "\(item.duration)s"
        cell.imageView?.image = UIImage(systemName: "line.3.horizontal")
        cell.accessoryType = .detailButton
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section] {
        case .available:
            addDetector(filteredDetectors[indexPath.row])
        case .main, .continuation:
            openEditor(for: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        openEditor(for: indexPath)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        sections[indexPath.section] != .available
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        sections[indexPath.section] == .available ? .none : .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        switch sections[indexPath.section] {
        case .main:
            selectedExercises.remove(at: indexPath.row)
        case .continuation:
            continuationExercises.remove(at: indexPath.row)
        case .available:
            break
        }
        tableView.reloadData()
        updateStartState()
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        sections[indexPath.section] != .available
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sections[sourceIndexPath.section] == sections[destinationIndexPath.section] else {
            tableView.reloadData()
            return
        }
        switch sections[sourceIndexPath.section] {
        case .main:
            let item = selectedExercises.remove(at: sourceIndexPath.row)
            selectedExercises.insert(item, at: destinationIndexPath.row)
        case .continuation:
            let item = continuationExercises.remove(at: sourceIndexPath.row)
            continuationExercises.insert(item, at: destinationIndexPath.row)
        case .available:
            break
        }
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        sections[sourceIndexPath.section] == sections[proposedDestinationIndexPath.section] ? proposedDestinationIndexPath : sourceIndexPath
    }
}

private final class ExerciseConfigViewController: UIViewController {
    private var exercise: BuiltWorkoutExercise
    private let onSave: (BuiltWorkoutExercise) -> Void
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    init(exercise: BuiltWorkoutExercise, onSave: @escaping (BuiltWorkoutExercise) -> Void) {
        self.exercise = exercise
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = BuildWorkoutViewController.displayName(for: exercise.detector)
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        configureLayout()
        buildRows()
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
        ])
    }

    private func buildRows() {
        addInfoRow(title: "Detector", value: exercise.detector)
        addStepperRow(title: "Duration", value: Double(exercise.duration), range: 5...300, step: 5, format: { "\(Int($0))s" }) { [weak self] value in
            self?.exercise.duration = Int(value)
        }
        addSegmentedRow(title: "Phone position", items: ["Default", "Floor", "Elevated"], selectedIndex: exercise.phonePositionChoice.rawValue) { [weak self] index in
            self?.exercise.phonePositionChoice = WorkoutPhonePositionChoice(rawValue: index) ?? .sdkDefault
        }
        addSegmentedRow(title: "Guidance mode", items: ["Default", "On", "Off"], selectedIndex: exercise.guidanceChoice.rawValue) { [weak self] index in
            self?.exercise.guidanceChoice = WorkoutTriStateChoice(rawValue: index) ?? .sdkDefault
        }
        addSegmentedRow(title: "Wide angle camera", items: ["Default", "On", "Off"], selectedIndex: exercise.wideAngleChoice.rawValue) { [weak self] index in
            self?.exercise.wideAngleChoice = WorkoutTriStateChoice(rawValue: index) ?? .sdkDefault
        }
        addSwitchRow(title: "Short intro", isOn: exercise.shortIntro) { [weak self] value in
            self?.exercise.shortIntro = value
        }
        addSwitchRow(title: "Pre-exercise countdown", isOn: exercise.playPreExerciseCountdown) { [weak self] value in
            self?.exercise.playPreExerciseCountdown = value
        }
        addSwitchRow(title: "Rep milestone voice", isOn: exercise.playRepMilestoneVoice) { [weak self] value in
            self?.exercise.playRepMilestoneVoice = value
        }
        addSegmentedRow(title: "Milestone interval", items: ["10 reps", "5 reps"], selectedIndex: exercise.repMilestoneInterval == 5 ? 1 : 0) { [weak self] index in
            self?.exercise.repMilestoneInterval = index == 1 ? 5 : 10
        }
        addSwitchRow(title: "Sound on each rep", isOn: exercise.playSoundOnEachRep) { [weak self] value in
            self?.exercise.playSoundOnEachRep = value
        }
        addSwitchRow(title: "Adaptive ROM feedback", isOn: exercise.adaptiveRomFeedbackEnabled) { [weak self] value in
            self?.exercise.adaptiveRomFeedbackEnabled = value
        }
        addStepperRow(title: "Adaptive warmup reps", value: Double(exercise.adaptiveRomWarmupReps), range: 1...5, step: 1, format: { "\(Int($0))" }) { [weak self] value in
            self?.exercise.adaptiveRomWarmupReps = Int(value)
        }
        addHeader("Stretch set")
        addSwitchRow(title: "Enable stretch set", isOn: exercise.stretchSetEnabled) { [weak self] value in
            self?.exercise.stretchSetEnabled = value
        }
        addStepperRow(title: "Stretch repetitions", value: Double(exercise.stretchSetRepetitions), range: 1...10, step: 1, format: { "\(Int($0))" }) { [weak self] value in
            self?.exercise.stretchSetRepetitions = Int(value)
        }
        addStepperRow(title: "Seconds per stretch", value: Double(exercise.stretchSetSeconds), range: 3...60, step: 1, format: { "\(Int($0))s" }) { [weak self] value in
            self?.exercise.stretchSetSeconds = Int(value)
        }
        addStepperRow(title: "Rest between stretches", value: Double(exercise.stretchSetRestSeconds), range: 0...30, step: 1, format: { "\(Int($0))s" }) { [weak self] value in
            self?.exercise.stretchSetRestSeconds = Int(value)
        }
    }

    private func addHeader(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 18, weight: .bold)
        stackView.addArrangedSubview(label)
    }

    private func addInfoRow(title: String, value: String) {
        let label = UILabel()
        label.text = "\(title): \(value)"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 0
        stackView.addArrangedSubview(label)
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
        addRow(row, label: label, trailingView: toggle)
    }

    private func addSegmentedRow(title: String, items: [String], selectedIndex: Int, onChange: @escaping (Int) -> Void) {
        let label = rowLabel(title)
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = selectedIndex
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addAction(UIAction { action in
            guard let sender = action.sender as? UISegmentedControl else { return }
            onChange(sender.selectedSegmentIndex)
        }, for: .valueChanged)
        let row = verticalRow(label: label, control: control)
        stackView.addArrangedSubview(row)
    }

    private func addStepperRow(title: String, value: Double, range: ClosedRange<Double>, step: Double, format: @escaping (Double) -> String, onChange: @escaping (Double) -> Void) {
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
            row.heightAnchor.constraint(equalToConstant: 44),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: stepper.leadingAnchor, constant: -12),
            valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            stepper.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            stepper.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -12),
        ])
        stackView.addArrangedSubview(row)
    }

    private func addRow(_ row: UIView, label: UILabel, trailingView: UIView) {
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 44),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingView.leadingAnchor, constant: -12),
            trailingView.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            trailingView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        stackView.addArrangedSubview(row)
    }

    private func verticalRow(label: UILabel, control: UIView) -> UIView {
        let row = UIStackView(arrangedSubviews: [label, control])
        row.axis = .vertical
        row.spacing = 6
        return row
    }

    private func rowLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    @objc private func doneTapped() {
        onSave(exercise)
        navigationController?.popViewController(animated: true)
    }
}

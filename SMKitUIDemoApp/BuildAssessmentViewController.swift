//
//  BuildAssessmentViewController.swift
//  SMKitUIDemoApp
//

import UIKit

protocol BuildAssessmentViewControllerDelegate: AnyObject {
    func buildAssessmentViewController(
        _ controller: BuildAssessmentViewController,
        didStartAssessment exercises: [BuiltAssessmentExercise],
        targetRepsProgress: Bool
    )

    func buildAssessmentViewController(
        _ controller: BuildAssessmentViewController,
        didStartRepTimerWorkout exercises: [BuiltAssessmentExercise]
    )
}

struct BuiltAssessmentExercise: Equatable {
    let id: UUID
    let entry: DemoExerciseCatalogEntry
    var scoringMode: DemoAssessmentScoringMode
    var duration: Int
    var targetReps: Int
    var targetTime: Int

    init(entry: DemoExerciseCatalogEntry) {
        self.id = UUID()
        self.entry = entry
        self.scoringMode = entry.defaultAssessmentMode
        self.duration = entry.defaultDuration
        self.targetReps = entry.defaultTargetReps
        self.targetTime = entry.defaultTargetTime
    }
}

final class BuildAssessmentViewController: UIViewController {
    weak var delegate: BuildAssessmentViewControllerDelegate?

    private enum Section: Int, CaseIterable {
        case selected
        case catalog
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let filterControl = UISegmentedControl(items: DemoExerciseFilter.allCases.map(\.title))
    private let targetRepsRow = UIView()
    private let targetRepsSwitch = UISwitch()
    private var startButton: UIBarButtonItem!
    private var clearButton: UIBarButtonItem!
    private var allEntries: [DemoExerciseCatalogEntry] = []
    private var selectedFilter: DemoExerciseFilter = .all
    private var selectedExercises: [BuiltAssessmentExercise] = []
    private var targetRepsProgress = false

    private var filteredEntries: [DemoExerciseCatalogEntry] {
        allEntries.filter { selectedFilter.contains($0.kind) }
    }

    private var hasRepScoredExercise: Bool {
        selectedExercises.contains { $0.scoringMode == .reps }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Build Assessment"
        view.backgroundColor = .systemBackground
        allEntries = ExerciseCatalog.allSupportedEntries()
        configureNavigation()
        configureLayout()
        updateStartState()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    private func configureNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        startButton = UIBarButtonItem(title: "Start", style: .done, target: self, action: #selector(startTapped))
        clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearTapped))
        navigationItem.rightBarButtonItems = [startButton, editButtonItem, clearButton]
    }

    private func configureLayout() {
        filterControl.selectedSegmentIndex = 0
        filterControl.addAction(UIAction { [weak self] action in
            guard let self, let sender = action.sender as? UISegmentedControl else { return }
            self.selectedFilter = DemoExerciseFilter.allCases[sender.selectedSegmentIndex]
            self.tableView.reloadSections(IndexSet(integer: Section.catalog.rawValue), with: .automatic)
        }, for: .valueChanged)
        filterControl.translatesAutoresizingMaskIntoConstraints = false

        let targetLabel = UILabel()
        targetLabel.text = "Target reps progress"
        targetLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        targetLabel.numberOfLines = 0
        targetLabel.translatesAutoresizingMaskIntoConstraints = false
        targetRepsSwitch.isOn = targetRepsProgress
        targetRepsSwitch.translatesAutoresizingMaskIntoConstraints = false
        targetRepsSwitch.addAction(UIAction { [weak self] action in
            guard let self, let sender = action.sender as? UISwitch else { return }
            self.targetRepsProgress = sender.isOn
            self.updateStartState()
        }, for: .valueChanged)
        targetRepsRow.translatesAutoresizingMaskIntoConstraints = false
        targetRepsRow.addSubview(targetLabel)
        targetRepsRow.addSubview(targetRepsSwitch)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(filterControl)
        view.addSubview(targetRepsRow)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            filterControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            filterControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            filterControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),

            targetRepsRow.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            targetRepsRow.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            targetRepsRow.topAnchor.constraint(equalTo: filterControl.bottomAnchor, constant: 8),
            targetRepsRow.heightAnchor.constraint(equalToConstant: 44),

            targetLabel.leadingAnchor.constraint(equalTo: targetRepsRow.leadingAnchor),
            targetLabel.trailingAnchor.constraint(lessThanOrEqualTo: targetRepsSwitch.leadingAnchor, constant: -12),
            targetLabel.centerYAnchor.constraint(equalTo: targetRepsRow.centerYAnchor),
            targetRepsSwitch.trailingAnchor.constraint(equalTo: targetRepsRow.trailingAnchor),
            targetRepsSwitch.centerYAnchor.constraint(equalTo: targetRepsRow.centerYAnchor),

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: targetRepsRow.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func updateStartState() {
        targetRepsSwitch.isEnabled = hasRepScoredExercise
        if !hasRepScoredExercise && targetRepsProgress {
            targetRepsProgress = false
            targetRepsSwitch.setOn(false, animated: true)
        }
        startButton?.isEnabled = !selectedExercises.isEmpty
        clearButton?.isEnabled = !selectedExercises.isEmpty
    }

    private func addEntry(_ entry: DemoExerciseCatalogEntry) {
        selectedExercises.append(BuiltAssessmentExercise(entry: entry))
        tableView.reloadData()
        updateStartState()
        tableView.scrollToRow(
            at: IndexPath(row: selectedExercises.count - 1, section: Section.selected.rawValue),
            at: .top,
            animated: true
        )
    }

    private func openEditor(for indexPath: IndexPath) {
        let item = selectedExercises[indexPath.row]
        let editor = AssessmentExerciseConfigViewController(exercise: item) { [weak self] updated in
            guard let self else { return }
            self.selectedExercises[indexPath.row] = updated
            self.tableView.reloadData()
            self.updateStartState()
        }
        navigationController?.pushViewController(editor, animated: true)
    }

    private func showValidationAlert(_ message: String) {
        let alert = UIAlertController(title: "Assessment Builder", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func clearTapped() {
        selectedExercises.removeAll()
        targetRepsProgress = false
        targetRepsSwitch.setOn(false, animated: true)
        tableView.reloadData()
        updateStartState()
    }

    @objc private func startTapped() {
        guard !selectedExercises.isEmpty else { return }
        let hasTimerBasedRepExercise = !targetRepsProgress && selectedExercises.contains { $0.scoringMode == .reps }
        let hasNonRepExercise = selectedExercises.contains { $0.scoringMode != .reps }

        if hasTimerBasedRepExercise && hasNonRepExercise {
            showValidationAlert("Use only reps exercises for timer mode, or enable target reps progress.")
            return
        }

        if hasTimerBasedRepExercise {
            delegate?.buildAssessmentViewController(self, didStartRepTimerWorkout: selectedExercises)
        } else {
            delegate?.buildAssessmentViewController(
                self,
                didStartAssessment: selectedExercises,
                targetRepsProgress: targetRepsProgress
            )
        }
    }
}

extension BuildAssessmentViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .selected: return selectedExercises.count
        case .catalog: return filteredEntries.count
        case nil: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .selected: return "Assessment (\(selectedExercises.count))"
        case .catalog: return "All Exercises"
        case nil: return nil
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .selected:
            return selectedExercises.isEmpty ? "Add at least one exercise to enable Start." : "Tap an exercise to edit scoring, duration, or targets."
        case .catalog:
            return filteredEntries.isEmpty ? "No supported movements found." : "Tap an exercise to add it."
        case nil:
            return nil
        }
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ??
            UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.selectionStyle = .default

        switch Section(rawValue: indexPath.section) {
        case .selected:
            let exercise = selectedExercises[indexPath.row]
            cell.textLabel?.text = "\(indexPath.row + 1). \(exercise.entry.displayName)"
            cell.detailTextLabel?.text = "\(exercise.scoringMode.title) - \(exercise.duration)s"
            cell.imageView?.image = UIImage(systemName: "line.3.horizontal")
            cell.accessoryType = .detailButton
        case .catalog:
            let entry = filteredEntries[indexPath.row]
            cell.textLabel?.text = entry.displayName
            cell.detailTextLabel?.text = "\(entry.detector) - \(entry.kind.title) - \(entry.assessmentModes.map(\.title).joined(separator: " / "))"
            cell.imageView?.image = UIImage(systemName: "plus.circle")
            cell.accessoryType = .none
        case nil:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Section(rawValue: indexPath.section) {
        case .selected:
            openEditor(for: indexPath)
        case .catalog:
            addEntry(filteredEntries[indexPath.row])
        case nil:
            break
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if Section(rawValue: indexPath.section) == .selected {
            openEditor(for: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        Section(rawValue: indexPath.section) == .selected
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete, Section(rawValue: indexPath.section) == .selected else { return }
        selectedExercises.remove(at: indexPath.row)
        tableView.reloadData()
        updateStartState()
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        Section(rawValue: indexPath.section) == .selected
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard Section(rawValue: sourceIndexPath.section) == .selected,
              Section(rawValue: destinationIndexPath.section) == .selected else {
            tableView.reloadData()
            return
        }
        let item = selectedExercises.remove(at: sourceIndexPath.row)
        selectedExercises.insert(item, at: destinationIndexPath.row)
    }
}

private final class AssessmentExerciseConfigViewController: UIViewController {
    private var exercise: BuiltAssessmentExercise
    private let onSave: (BuiltAssessmentExercise) -> Void
    private let stackView = UIStackView()

    init(exercise: BuiltAssessmentExercise, onSave: @escaping (BuiltAssessmentExercise) -> Void) {
        self.exercise = exercise
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = exercise.entry.displayName
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        configureLayout()
        buildRows()
    }

    private func configureLayout() {
        let scrollView = UIScrollView()
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
        addInfoRow(title: "Detector", value: exercise.entry.detector)
        addInfoRow(title: "Type", value: exercise.entry.kind.title)
        addStepperRow(title: "Duration", value: exercise.duration, range: 1...60, unit: "sec") { [weak self] value in
            self?.exercise.duration = value
        }
        if exercise.entry.assessmentModes.count > 1 {
            addSegmentedRow(
                title: "Scoring",
                items: exercise.entry.assessmentModes.map(\.title),
                selectedIndex: exercise.entry.assessmentModes.firstIndex(of: exercise.scoringMode) ?? 0
            ) { [weak self] index in
                guard let self else { return }
                self.exercise.scoringMode = self.exercise.entry.assessmentModes[index]
                self.rebuildRows()
            }
        } else {
            addInfoRow(title: "Scoring", value: exercise.scoringMode.title)
        }

        switch exercise.scoringMode {
        case .reps:
            addStepperRow(title: "Target reps", value: exercise.targetReps, range: 1...10, unit: "reps") { [weak self] value in
                self?.exercise.targetReps = value
            }
        case .time:
            addStepperRow(title: "Target time", value: exercise.targetTime, range: 1...60, unit: "sec") { [weak self] value in
                self?.exercise.targetTime = value
            }
        case .rom:
            addInfoRow(title: "Target ROM", value: exercise.entry.targetRom ?? "Unavailable")
        }
    }

    private func rebuildRows() {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        buildRows()
    }

    private func addInfoRow(title: String, value: String) {
        let label = UILabel()
        label.text = "\(title): \(value)"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 0
        stackView.addArrangedSubview(label)
    }

    private func addSegmentedRow(title: String, items: [String], selectedIndex: Int, onChange: @escaping (Int) -> Void) {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = selectedIndex
        control.addAction(UIAction { action in
            guard let sender = action.sender as? UISegmentedControl else { return }
            onChange(sender.selectedSegmentIndex)
        }, for: .valueChanged)
        let row = UIStackView(arrangedSubviews: [label, control])
        row.axis = .vertical
        row.spacing = 6
        stackView.addArrangedSubview(row)
    }

    private func addStepperRow(
        title: String,
        value: Int,
        range: ClosedRange<Int>,
        unit: String,
        onChange: @escaping (Int) -> Void
    ) {
        let row = UIView()
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        let valueLabel = UILabel()
        valueLabel.text = "\(value) \(unit)"
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 15, weight: .regular)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        let stepper = UIStepper()
        stepper.minimumValue = Double(range.lowerBound)
        stepper.maximumValue = Double(range.upperBound)
        stepper.value = Double(value)
        stepper.stepValue = 1
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.addAction(UIAction { action in
            guard let sender = action.sender as? UIStepper else { return }
            let newValue = Int(sender.value)
            valueLabel.text = "\(newValue) \(unit)"
            onChange(newValue)
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

    @objc private func doneTapped() {
        onSave(exercise)
        navigationController?.popViewController(animated: true)
    }
}

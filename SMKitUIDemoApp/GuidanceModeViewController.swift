//
//  GuidanceModeViewController.swift
//  SMKitUIDemoApp
//

import UIKit

protocol GuidanceModeViewControllerDelegate: AnyObject {
    func guidanceModeViewController(
        _ controller: GuidanceModeViewController,
        didStart detector: String
    )
}

final class GuidanceModeViewController: UITableViewController {
    weak var delegate: GuidanceModeViewControllerDelegate?

    private var exercises: [DemoGuidanceExercise] = []

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Guidance Mode"
        exercises = ExerciseCatalog.guidanceEntries()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GuidanceCell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        exercises.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Supported Guidance Exercises"
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if exercises.isEmpty {
            return "No guidance-mode exercises were reported by the configured SDK."
        }
        return "Tap an exercise to start it with guidance mode enabled."
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GuidanceCell", for: indexPath)
        let exercise = exercises[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = exercise.displayName
        content.secondaryText = exercise.detector
        content.image = exercise.recommended ? UIImage(systemName: "star.fill") : nil
        content.imageProperties.tintColor = .systemOrange
        cell.contentConfiguration = content
        cell.tintColor = exercise.recommended ? .systemOrange : nil
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.guidanceModeViewController(self, didStart: exercises[indexPath.row].detector)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

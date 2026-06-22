//
//  BuiltInAssessmentViewController.swift
//  SMKitUIDemoApp
//

import UIKit
import SMBase

protocol BuiltInAssessmentViewControllerDelegate: AnyObject {
    func builtInAssessmentViewController(
        _ controller: BuiltInAssessmentViewController,
        didSelect type: AssessmentTypes
    )
}

final class BuiltInAssessmentViewController: UITableViewController {
    weak var delegate: BuiltInAssessmentViewControllerDelegate?

    private let assessmentTypes = AssessmentTypes.allCases
        .filter { $0 != .Custom }
        .sorted { $0.displayTitle < $1.displayTitle }

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Built-In Assessments"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AssessmentCell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assessmentTypes.count
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "Starts the selected SDK built-in assessment with the current demo UI settings."
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssessmentCell", for: indexPath)
        let type = assessmentTypes[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = type.displayTitle
        content.secondaryText = type.rawValue
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.builtInAssessmentViewController(self, didSelect: assessmentTypes[indexPath.row])
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

private extension AssessmentTypes {
    var displayTitle: String {
        switch self {
        case .Fitness: return "Fitness"
        case .Body360: return "Body 360"
        case .Cardio: return "Cardio"
        case .Strength: return "Strength"
        case .Custom: return "Custom"
        }
    }
}

//
//  MainView.swift
//  SMKitUIDemoApp
//
//  Created by netanel-yerushalmi on 18/03/2024.
//

import SwiftUI
import SMKitUI

struct DemoAssessmentSummaryHistoryItem: Identifiable {
    let id = UUID()
    let completedAt: Date
    let summary: WorkoutSummaryData?
    let score: Int?
    let completedCount: Int
    let totalCount: Int
    let duration: TimeInterval

    var scoreText: String {
        score.map { "\($0)/100" } ?? "--"
    }

    var durationText: String {
        let seconds = Int(duration.rounded())
        let minutes = seconds / 60
        let remainder = seconds % 60
        return minutes > 0 ? "\(minutes)m \(remainder)s" : "\(remainder)s"
    }

    var completedText: String {
        "\(completedCount)/\(totalCount) movements"
    }
}

final class DemoAssessmentSummaryHistoryStore: ObservableObject {
    static let shared = DemoAssessmentSummaryHistoryStore()

    @Published private(set) var items: [DemoAssessmentSummaryHistoryItem] = []

    private init() {}

    func add(_ item: DemoAssessmentSummaryHistoryItem) {
        items.insert(item, at: 0)
    }

    func clear() {
        items.removeAll()
    }
}

struct MainView: View {
    @ObservedObject var authModel = AuthManager.shared
    @ObservedObject private var summaryHistory = DemoAssessmentSummaryHistoryStore.shared
    @State private var futureAssessmentGuidanceEnabled = true

    let buildWorkoutWasPressed:()->Void
    let buildAssessmentWasPressed:()->Void
    let startAssessmentWasPressed:()->Void
    let startCustomAssessmet:(Bool)->Void
    let summaryHistoryItemWasPressed:(DemoAssessmentSummaryHistoryItem)->Void
    let guidanceModeWasPressed:()->Void
    let uiSettingsWasPressed:()->Void

    private func workoutButton(_ title: String, isProminent: Bool = false, action: @escaping ()->Void) -> some View {
        Button {
            if authModel.didFinishAuth { action() }
        } label: {
            HStack(spacing: 8) {
                if isProminent {
                    Image(systemName: "sparkles")
                }
                Text(title)
            }
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 48)
                .foregroundStyle(isProminent ? .white : .primary)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isProminent ? Color.accentColor : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isProminent ? Color.accentColor.opacity(0.3) : Color.primary, lineWidth: 1)
                )
                .shadow(
                    color: isProminent ? Color.accentColor.opacity(0.28) : Color.clear,
                    radius: isProminent ? 10 : 0,
                    y: isProminent ? 4 : 0
                )
        }
        .padding(.horizontal, 24)
        .overlay(
            ZStack {
                if !authModel.didFinishAuth {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .padding()
                }
            },
            alignment: .trailing
        )
    }

    private var futureAssessmentControls: some View {
        VStack(spacing: 10) {
            workoutButton("Start Future Assessment", isProminent: true) {
                startCustomAssessmet(futureAssessmentGuidanceEnabled)
            }

            Toggle(isOn: $futureAssessmentGuidanceEnabled) {
                Label("Future Assessment Guidance", systemImage: "figure.walk.motion")
                    .font(.subheadline.weight(.semibold))
            }
            .toggleStyle(.switch)
            .disabled(!authModel.didFinishAuth)
            .padding(.horizontal, 24)
        }
    }

    private var summaryHistorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Label("Summary History", systemImage: "clock.arrow.circlepath")
                    .font(.headline)

                Spacer()

                if !summaryHistory.items.isEmpty {
                    Button(action: summaryHistory.clear) {
                        Image(systemName: "trash")
                            .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("Clear summary history")
                }
            }
            .padding(.horizontal, 24)

            if summaryHistory.items.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("No summaries yet")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
                .padding(.horizontal, 24)
            } else {
                VStack(spacing: 8) {
                    ForEach(summaryHistory.items) { item in
                        Button {
                            summaryHistoryItemWasPressed(item)
                        } label: {
                            SummaryHistoryRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                workoutButton("BUILD WORKOUT", action: buildWorkoutWasPressed)
                workoutButton("BUILD ASSESSMENT", action: buildAssessmentWasPressed)
                workoutButton("START BUILT-IN ASSESSMENT", action: startAssessmentWasPressed)
                futureAssessmentControls
                summaryHistorySection
                workoutButton("GUIDANCE MODE", action: guidanceModeWasPressed)

                Button(action: uiSettingsWasPressed) {
                    Label("UI Settings", systemImage: "slider.horizontal.3")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 24)
        }
    }
}

private struct SummaryHistoryRow: View {
    let item: DemoAssessmentSummaryHistoryItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title3)
                .foregroundStyle(Color(uiColor: .systemTeal))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("Future Assessment")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(item.completedAt, format: .dateTime.month(.abbreviated).day().hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)

                Text("\(item.completedText) - \(item.durationText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text(item.scoreText)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                Text("score")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 58, alignment: .trailing)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    MainView(
        buildWorkoutWasPressed: {},
        buildAssessmentWasPressed: {},
        startAssessmentWasPressed: {},
        startCustomAssessmet: { _ in },
        summaryHistoryItemWasPressed: { _ in },
        guidanceModeWasPressed: {},
        uiSettingsWasPressed: {}
    )
}

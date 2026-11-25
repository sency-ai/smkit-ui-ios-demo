//
//  MainView.swift
//  SMKitUIDemoApp
//
//  Created by netanel-yerushalmi on 18/03/2024.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var authModel = AuthManager.shared
    @ObservedObject var presetState: DemoPresetState
    let mobilityFlowWasPressed:()->Void
    let exampleWorkoutWasPressed:()->Void
    let buildWorkoutWasPressed:()->Void
    let buildAssessmentWasPressed:()->Void
    let startAssessmentWasPressed:()->Void
    let startCustomAssessmet:()->Void
    let guidanceModeWasPressed:()->Void
    let uiSettingsWasPressed:()->Void

    private func workoutButton(_ title: String, action: @escaping ()->Void) -> some View {
        Button {
            if authModel.didFinishAuth { action() }
        } label: {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(RoundedRectangle(cornerRadius: 12).stroke())
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

    private func presetButton(_ title: String, systemImage: String, disabled: Bool = false, action: @escaping ()->Void) -> some View {
        Button {
            if authModel.didFinishAuth { action() }
        } label: {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.accentColor))
                .foregroundColor(.white)
        }
        .disabled(disabled)
        .opacity(disabled ? 0.6 : 1)
        .padding(.horizontal, 24)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                presetButton(
                    presetState.preparingPreset == DemoPresets.mobilityFlowName
                        ? "Preparing Mobility Flow…"
                        : DemoPresets.mobilityFlowName,
                    systemImage: "figure.walk",
                    disabled: presetState.preparingPreset != nil,
                    action: mobilityFlowWasPressed
                )
                presetButton(DemoPresets.exampleWorkoutName, systemImage: "flame.fill", action: exampleWorkoutWasPressed)

                workoutButton("BUILD WORKOUT", action: buildWorkoutWasPressed)
                workoutButton("BUILD ASSESSMENT", action: buildAssessmentWasPressed)
                workoutButton("START BUILT-IN ASSESSMENT", action: startAssessmentWasPressed)
                workoutButton("START SAMPLE ASSESSMENT", action: startCustomAssessmet)
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

#Preview {
    MainView(
        presetState: DemoPresetState(),
        mobilityFlowWasPressed: {},
        exampleWorkoutWasPressed: {},
        buildWorkoutWasPressed: {},
        buildAssessmentWasPressed: {},
        startAssessmentWasPressed: {},
        startCustomAssessmet: {},
        guidanceModeWasPressed: {},
        uiSettingsWasPressed: {}
    )
}
